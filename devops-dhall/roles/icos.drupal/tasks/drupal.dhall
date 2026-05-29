-- Auto-generated from ../../../../devops/roles/icos.drupal/tasks/drupal.yml

let Task = ../../../types/Task.dhall

in  [
    Task::{
      name = Some "Create project directory",
      file = Some (Task.Poly_file.Record {
          path = Some "{{ project_dir }}",
          state = Some "directory",
          owner = None Text,
          group = None Text,
          name = None Text,
          mode = None Text,
          dest = None Text,
          recurse = None Bool,
          src = None Text
      })
    }
  , Task::{
      name = Some "Pull source code from git",
      git = Some {
        repo = "https://github.com/ICOS-Carbon-Portal/drupal",
        version = Some "{{ git_version | default('master') }}",
        dest = "{{ project_dir }}",
        force = Some True,
        update = None Text,
        key_file = None Text
    }
    }
  , Task::{
      name = Some "Create {{ project_dir }}/config/ directory",
      file = Some (Task.Poly_file.Str "path={{ project_dir }}/config/ state=directory recurse=yes")
    }
  , Task::{
      name = Some "Copy uploads config",
      copy = Some {
        dest = "{{ project_dir }}/config/uploads.ini",
        mode = None Text,
        content = None Text,
        src = Some "uploads.ini",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    }
    }
  , Task::{
      name = Some "Create {{ project_dir }}/files/private/ directory",
      file = Some (Task.Poly_file.Str "path={{ project_dir }}/files/private/ state=directory recurse=yes")
    }
  , Task::{
      name = Some "Create {{ project_dir }}/files/default/files/ directory",
      file = Some (Task.Poly_file.Str "path={{ project_dir }}/files/default/files/ state=directory recurse=yes")
    }
  , Task::{
      name = Some "Copy settings.php",
      template = Some {
        src = "settings.php.j2",
        dest = "{{ project_dir }}/files/default/settings.php",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    }
    }
  , Task::{
      name = Some "Create {{ project_dir }}/docker/ directory",
      file = Some (Task.Poly_file.Str "path={{ project_dir }}/docker/ state=directory recurse=yes")
    }
  , Task::{
      name = Some "Copy docker-compose.yml",
      template = Some {
        src = "docker-compose.yml.j2",
        dest = "{{ project_dir }}/docker/docker-compose.yml",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    },
      register = Some "docker_compose_yml"
    }
  , Task::{
      name = Some "Copy environment file",
      template = Some {
        src = "env.j2",
        dest = "{{ project_dir }}/docker/.env",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    }
    }
  , Task::{
      name = Some "Create {{ project_dir }}/composer/ directory",
      file = Some (Task.Poly_file.Str "path={{ project_dir }}/composer/ state=directory recurse=yes")
    }
  , Task::{
      name = Some "Copy composer.json",
      template = Some {
        src = "composer.json.j2",
        dest = "{{ project_dir }}/composer/composer.json",
        mode = None Text,
        variable_start_string = None Text,
        variable_end_string = None Text,
        lstrip_blocks = None Bool,
        validate = None Text,
        backup = None Bool,
        owner = None Text,
        group = None Text
    }
    }
  , Task::{
      name = Some "Copy robots.txt",
      copy = Some {
        dest = "{{ project_dir }}/composer/robots.txt.append",
        mode = None Text,
        content = None Text,
        src = Some "{{ robots_txt }}",
        backup = None Bool,
        owner = None Text,
        group = None Text,
        force = None Text,
        validate = None Text
    },
      when = Some [ "robots_txt is defined" ]
    }
  , Task::{
      name = Some "Enable maintenance mode",
      command = Some "docker exec {{website}}_drupal_1 drush maint:set 1",
      when = Some [ "update | bool" ]
    }
  , Task::{
      name = Some "(Re)start docker containers",
      `community.docker.docker_compose_v2` = Some {
        project_src = "{{ project_dir }}/docker",
        state = Some "present",
        pull = Some "always",
        services = None ((List Text)),
        build = None Text
    }
    }
  , Task::{
      name = Some "Check private directory owner",
      command = Some "docker exec {{website}}_drupal_1 stat -c '%U' /var/www/private/",
      register = Some "private_directory_owner",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
  , Task::{
      name = Some "Change private directory owner",
      command = Some "docker exec {{website}}_drupal_1 chown -R www-data:www-data /var/www/private/",
      when = Some [ "private_directory_owner.stdout != \"www-data\"" ]
    }
  , Task::{
      name = Some "Check files directory owner",
      command = Some "docker exec {{website}}_drupal_1 stat -c '%U' /var/www/private/",
      register = Some "files_directory_owner",
      changed_when = Some (Task.Poly_changed_when.Bool False)
    }
  , Task::{
      name = Some "Change files directory owner",
      command = Some "docker exec {{website}}_drupal_1 chown -R www-data:www-data /var/www/html/sites/default/files",
      when = Some [ "files_directory_owner.stdout != \"www-data\"" ]
    }
  , Task::{
      name = Some "Composer update",
      command = Some "docker exec {{website}}_drupal_1 composer update",
      when = Some [ "update | bool" ],
      register = Some "result",
      changed_when = Some (Task.Poly_changed_when.Str "\"Package operations\" in result.stderr")
    }
  , Task::{
      name = Some "Update database",
      command = Some "docker exec {{website}}_drupal_1 drush updb",
      when = Some [ "update | bool" ]
    }
  , Task::{
      name = Some "Disable maintenance mode",
      command = Some "docker exec {{website}}_drupal_1 drush maint:set 0",
      when = Some [ "update | bool" ]
    }
  , Task::{ name = Some "Clear caches", command = Some "docker exec {{website}}_drupal_1 drush cr" }
]
