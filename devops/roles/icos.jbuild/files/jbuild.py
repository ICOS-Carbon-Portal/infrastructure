#!/opt/jbuild/venv/bin/python3
# Standard library imports
from collections import OrderedDict
from pathlib import Path, PosixPath
from subprocess import Popen, PIPE, STDOUT, run
import os
import subprocess
import sys

# Related third party imports
import click
import docker
import git

# TODO: detect simultaneous builds
# TODO: mapping of username to branch names?
# TODO: autoclean images on exploredata

def log(msg: str, lvl: str, input_logic: bool = False, end: str = '\n') -> str | None:
    """
    Print a color-coded log message.

    Messages are prefixed with the log level (e.g. "[RUN]") and styled
    by color. The "DIE" level writes to stderr; all others go to
    stdout. If `input_logic` is True, the message is shown as a prompt
    and the user's input is returned.

    Args:
        msg (str): Message text.
        lvl (str): Log level ('INIT', 'RUN', 'INFO', 'DEBUG', 'USER', 'DIE').
        input_logic (bool): Prompt for input if True. Defaults to False.
        end (str): Line ending, use '' to overwrite a line. Defaults to '\n'.

    Returns:
        str | None: User input if `input_logic` is True, otherwise None.
    """
    allowed_levels = {'INIT', 'RUN', 'INFO', 'DEBUG', 'USER', 'DIE'}
    lvl = lvl.upper()
    if lvl not in allowed_levels:
        raise ValueError(f"Invalid level '{lvl}'. Allowed levels: {allowed_levels}")

    level_colors = {
        'INIT': 'cyan',
        'RUN': 'green',
        'INFO': 'bright_white',
        'DEBUG': 'magenta',
        'USER': 'bright_blue',
        'DIE': 'bright_red',
    }
    color = level_colors[lvl]
    styled_msg = click.style(f'[{lvl}] {msg}', fg=color)
    stream = sys.stderr if lvl == 'DIE' else sys.stdout

    if input_logic:
        return input(styled_msg)
    else:
        click.echo(styled_msg, nl=(end != ''), file=stream)
        if lvl == 'DIE': sys.exit(1)
        return None


class JBuildContext:
    def __init__(self, repo=None):
        self.git_py_repo = None
        self.jbuild_dir = None
        self.registry = None
        self.repo = repo
        self.repo_dir = None
        self.user = None

        if repo:
            self.init_repo(repo)

    def init_repo(self, repo):
        """Initialize jbuild and repository directories."""
        self.jbuild_dir = Path.home() / 'jbuild'
        self.jbuild_dir.mkdir(parents=True, exist_ok=True)
        self.registry = 'registry.icos-cp.eu'
        self.repo = repo
        self.user = os.environ['USER']
        if repo == 'jupyter':
            self.repo_dir = self.jbuild_dir / 'jupyter'
            repo_url = 'https://github.com/ICOS-Carbon-Portal/jupyter/'
        else:
            self.repo_dir = self.jbuild_dir / 'pid4notebooks'
            repo_url = 'https://github.com/ICOS-Carbon-Portal/pid4notebooks/'

        if not self.repo_dir.exists():
            log(f'Cloning {repo} repository into {self.repo_dir}', 'INIT')
            run(['git', 'clone', repo_url, str(self.repo_dir)], check=True)
            assert self.repo_dir.exists()
            log(f'Cloned {repo} into {self.repo_dir}','INIT')
        else:
            log(f'Using existing repo at {self.repo_dir}', 'INIT')

        # Initialize GitPython Repo object
        self.git_py_repo = git.Repo(self.repo_dir)
        log(f'Fetching latest changes from remote', 'INIT')
        self.git_py_repo.remotes.origin.fetch(verbose=True)
        log(10*'-', 'INIT')


def yesno(msg):
    if not sys.stdin.isatty():
        die(f'No terminal, cannot answer question {msg}')
    while True:
        ans = input(f'{msg} [yn] ').lower()
        if ans == 'y':
            return True
        if ans == 'n':
            return False


def ask_for_branch(git_py_repo: git.Repo) -> None:
    refs = OrderedDict((r.name[len('origin/'):], r) for r in
                       sorted(git_py_repo.refs, reverse=True,
                              key=lambda git_ref: git_ref.commit.authored_datetime)
                       if (r.is_remote() and r.remote_name == 'origin'
                           and not r.name.endswith('HEAD')))
    latest_branches = list(refs.keys())[:5]
    while True:
        log(f'The newest {len(latest_branches)} branches are: \n  ' + '\n  '.join(latest_branches), 'USER')
        branch = log(f'Please specify which branch to build (blank for {latest_branches[0]}): ',
                     'USER',
                     True)
        branch = branch if branch != '' else latest_branches[0]
        if not branch in refs:
            log(f"Cannot find branch '{branch}'", 'USER')
        else:
            ref = refs[branch]
            log(10 * '-', 'USER')
            break
    log(f'Checking out {ref}', 'RUN')
    try:
        ref.checkout()
    except git.GitCommandError as err:
        log(str(err), 'DIE')


def build(dockerfile: Path, jbuild_ctx: JBuildContext) -> str:
    parent_tag = dockerfile.parents[1].name
    if 'icosbase' in parent_tag:
        build_args = []
    else:
        build_args = [f'--build-arg=BASE=icosbase-{jbuild_ctx.user}']
    context = dockerfile.parents[1] / 'content'
    # Tag the images as "icos-notebooks-zelda"
    tag = f'{parent_tag}-{jbuild_ctx.user}'
    log_path = jbuild_ctx.jbuild_dir / f'{tag.replace("-", "_")}.log'
    log(f'Building {tag} - complete log in {log_path}', 'RUN')
    with open(log_path, 'w', buffering=1) as log_file:
        cmd = ['docker', 'build', *build_args, '--tag', tag, context, '-f', dockerfile]
        print(' '.join(map(str, cmd)), file=log_file)
        r = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        for n, line in enumerate(r.stdout):
            log_file.write(line)
            if line.startswith('Step '):
                # Only print the 'Step x/y' part.
                log(f'\r  {line.split(":")[0]}\r', 'RUN', end='')
        # We need to wait() until returncode is set.
        r.wait()
        if r.returncode != 0:
            log(f'docker build failed - see {log_path} for details', 'DIE')
    log(f'Successfully built {tag}', 'RUN')
    return parent_tag


def push(env: str, parent_tag:  str, jbuild_ctx: JBuildContext):
    client = docker.from_env()
    local_tag = f'{parent_tag}-{jbuild_ctx.user}'
    img = client.images.get(local_tag)
    registry_tag = f'{jbuild_ctx.registry}/exploredata.{env}.{parent_tag}'
    img.tag(registry_tag)
    for update in client.images.push(registry_tag, stream=True, decode=True):
        # This will detect any error reported by the registry for this
        # specific chunk of push.
        if error := update.get('error'):
            log(f"Error while pushing '{registry_tag}' to registry - {error}", 'DIE')
        log(f'Pushing {registry_tag} - {update.get("id")}\r', 'RUN', end='')
    log(f'Pushing {registry_tag} - done', 'RUN')

    if env in ('prod', 'test'):
        env_tag = f'{env}.{parent_tag}'
        cmd = ['edctl', 'pull', registry_tag]
        push_tag = registry_tag
    # else:
    #     cmd = ["jyctl", "pull"]
    #     push_tag = "registry.icos-cp.eu/icosbase"
    # REMOTE PULL
    hdr = "Remote is pulling %s - %%-15s" % push_tag
    print(hdr % "starting" + "\r", end="")
    p = Popen(cmd, stdout=PIPE, stderr=STDOUT, text=True)
    for line in p.stdout:
        line = line.strip()
        # This is the last line and contains the short_id of the image.
        if line.startswith("short_id"):
            short_id = line.strip().split()[-1]
            # The image as received on exploredata is the same as we pushed.
            assert short_id == img.short_id, (short_id, img.short_id)
        # The other lines are status updates.
        elif line == "done":
            print(hdr % "done")
        else:
            print(hdr % line + "\r", end="")
    p.wait()
    if p.returncode != 0:
        die("%s failed" % " ".join(cmd))

    # # REMOTE PULL
    # hdr = "Remote is pulling %s - %%-15s" % push_tag
    # print(hdr % "starting" + "\r", end="")
    # p = Popen(cmd, stdout=PIPE, stderr=STDOUT, text=1)
    # for line in p.stdout:
    #     line = line.strip()
    #     # This is the last line and contains the short_id of the image.
    #     if line.startswith("short_id"):
    #         short_id = line.strip().split()[-1]
    #         # The image as received on exploredata is the same as we pushed.
    #         assert short_id == img.short_id, (short_id, img.short_id)
    #     # The other lines are status updates.
    #     elif line == "done":
    #         print(hdr % "done")
    #     else:
    #         print(hdr % line + "\r", end="")
    # p.wait()
    # if p.returncode != 0:
    #     die("%s failed" % " ".join(cmd))

    # PUSH TEMPLATES
    # push_templates(what)


# We'll use rsync but route it through the remote edctl command (which in turn
# will hand over to rrsync(1)). This requires some unusual options.
def push_templates(what):
    tdir = JUPYDIR.joinpath("templates")
    if what in ("prod", "test"):
        cmd = "edctl templates %s" % what
        tdir = tdir.joinpath("exploredata")
        host = "edctl:"
    else:
        cmd = "jyctl templates"
        tdir = tdir.joinpath("jupyter")
        host = "jyctl:"
    print('Pushing %s/ to "%s"' % (tdir, what))
    run(["rsync", "--rsync-path", cmd, "-vrplt", "%s/" % tdir, host], check=1)


def sync_notebooks():
    # Sync notebooks and delete extraneous files from destination
    # directory.
    run(["rsync", "-vtr", "--delete", "%s/" % JUPYDIR.joinpath("notebooks"), "projectcommon:"], check=1)


# CLI
@click.group()
@click.option(
    '--repo',
    type=click.Choice(['jupyter', 'pid4notebooks']),
    required=True,
    help='GitHub repository to operate on.',
)
@click.pass_context
def cli(ctx, repo):
    if ctx.obj is None:
        ctx.obj = JBuildContext()
    ctx.obj.init_repo(repo)

@cli.command("templates", help="Push templates")
@click.argument("what", type=click.Choice(["test", "prod", "jupyter"]))
@click.argument("branch", required=False)
@click.option("--fetch/--no-fetch", default=True, help="Fetch from github")
def cli_templates(what, branch, fetch):
    maybe_fetch(branch, fetch)
    push_templates(what)


@cli.command("info", help="Shows images in use.")
def cli_info():
    r = run(["edctl", "images"], text=1, capture_output=1)
    test = None
    prod = None
    for line in r.stdout.splitlines():
        # Standard output from 'docker images', minus the header line.
        repo, tag, iid, *_ = line.split()
        if repo.endswith("test.notebook"):
            test = iid
        if repo.endswith("prod.notebook"):
            prod = iid
    client = docker.from_env()
    for name, tag in (("test", test), ("prod", prod)):
        if tag is None:
            print(f"Exploredata has no {name}.notebook image (!?).")
        else:
            try:
                img = client.images.get(tag)
            except docker.errors.ImageNotFound:
                print(
                    f"There is no local image corresponding to the " f"{name}.notebook image in exploredata"
                )
                continue
            # If one of the local tags starts with 'exploredata-' then it contains
            # the name of the user that built the image now used on
            # exploredata.
            user_tag = [t for t in img.tags if t.startswith("exploredata-") and t.endswith(":latest")]
            if len(user_tag) == 1:
                print(f"Exploredata is using the " f"{user_tag[0]} image as its {name}.notebook")
            else:
                print(f"Exploredata is using the {img} as its {name}.notebook.")


@cli.command('run', help='Build, push images, sync notebooks')
@click.pass_context
def cli_run(ctx):
    os.chdir(ctx.obj.repo_dir)
    ask_for_branch(ctx.obj.git_py_repo)
    builds = []
    for df in ctx.obj.repo_dir.rglob('Dockerfile'):
        if any(p.name == 'icosbase' for p in df.parents):
            # "icosbase" image goes first.
            builds.insert(0, df)
        elif not df.match('*/hub/Dockerfile'):
            builds.append(df)
    parent_tags = []
    for dockerfile_path in builds:
        parent_tags.append(build(dockerfile_path, ctx.obj))
    for tag in parent_tags:
        push('test', tag, ctx.obj)
    msg = ('Explore-Test has been updated, please check it manually. '
           'Do you now want to deploy Explore-Data as well?')
    user_answer = log(msg, 'USER', True)
    if user_answer == 'y':
        for tag in parent_tags:
            push('prod', tag, ctx.obj)
    # TODO
    # if yesno("Do you want to push the new docker image to jupyter?"):
    #     push("jupyter", icosbase_tag)
    #
    # if yesno("Do you want to sync notebooks to jupyter.icos-cp.eu?"):
    #     sync_notebooks()


@cli.command('sync', help='Sync notebooks to jupyter.icos-cp.eu:/project/common')
def cli_sync():
    sync_notebooks()


if __name__ == '__main__':
    cli(obj=None)
