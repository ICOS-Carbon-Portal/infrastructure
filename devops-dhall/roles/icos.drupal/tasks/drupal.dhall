-- Auto-generated from drupal.yml

let Task =
    { Type =
        { name : Text
    , file : Optional Text
    , git : Optional ({ repo : Text, version : Text, dest : Text, force : Bool })
    , copy : Optional ({ src : Text, dest : Text })
    , template : Optional ({ src : Text, dest : Text })
    , register : Optional Text
    , when : Optional Text
    , command : Optional Text
    , `community.docker.docker_compose_v2` : Optional ({ project_src : Text, state : Text, pull : Text })
    , changed_when : Optional Text
  }
    , default =
        { file = None Text
    , git = None ({ repo : Text, version : Text, dest : Text, force : Bool })
    , copy = None ({ src : Text, dest : Text })
    , template = None ({ src : Text, dest : Text })
    , register = None Text
    , when = None Text
    , command = None Text
    , `community.docker.docker_compose_v2` = None ({ project_src : Text, state : Text, pull : Text })
    , changed_when = None Text
  }
    }

in  [
    Task::{
      name = "Create project directory",
      file = Some { path = "{{ project_dir }}", state = "directory" }
    }
  , Task::{
      name = "Pull source code from git",
      git = Some {
        repo = "https://github.com/ICOS-Carbon-Portal/drupal"
      , version = "{{ git_version | default('master') }}"
      , dest = "{{ project_dir }}"
      , force = True
    }
    }
  , Task::{
      name = "Create {{ project_dir }}/config/ directory",
      file = Some "path={{ project_dir }}/config/ state=directory recurse=yes"
    }
  , Task::{
      name = "Copy uploads config",
      copy = Some { src = "uploads.ini", dest = "{{ project_dir }}/config/uploads.ini" }
    }
  , Task::{
      name = "Create {{ project_dir }}/files/private/ directory",
      file = Some "path={{ project_dir }}/files/private/ state=directory recurse=yes"
    }
  , Task::{
      name = "Create {{ project_dir }}/files/default/files/ directory",
      file = Some "path={{ project_dir }}/files/default/files/ state=directory recurse=yes"
    }
  , Task::{
      name = "Copy settings.php",
      template = Some {
        src = "settings.php.j2"
      , dest = "{{ project_dir }}/files/default/settings.php"
    }
    }
  , Task::{
      name = "Create {{ project_dir }}/docker/ directory",
      file = Some "path={{ project_dir }}/docker/ state=directory recurse=yes"
    }
  , Task::{
      name = "Copy docker-compose.yml",
      template = Some {
        src = "docker-compose.yml.j2"
      , dest = "{{ project_dir }}/docker/docker-compose.yml"
    },
      register = Some "docker_compose_yml"
    }
  , Task::{
      name = "Copy environment file",
      template = Some { src = "env.j2", dest = "{{ project_dir }}/docker/.env" }
    }
  , Task::{
      name = "Create {{ project_dir }}/composer/ directory",
      file = Some "path={{ project_dir }}/composer/ state=directory recurse=yes"
    }
  , Task::{
      name = "Copy composer.json",
      template = Some { src = "composer.json.j2", dest = "{{ project_dir }}/composer/composer.json" }
    }
  , Task::{
      name = "Copy robots.txt",
      copy = Some {
        src = "{{ robots_txt }}"
      , dest = "{{ project_dir }}/composer/robots.txt.append"
    },
      when = Some "robots_txt is defined"
    }
  , Task::{
      name = "Enable maintenance mode",
      when = Some "update | bool",
      command = Some "docker exec {{website}}_drupal_1 drush maint:set 1"
    }
  , Task::{
      name = "(Re)start docker containers",
      `community.docker.docker_compose_v2` = Some { project_src = "{{ project_dir }}/docker", state = "present", pull = "always" }
    }
  , Task::{
      name = "Check private directory owner",
      register = Some "private_directory_owner",
      command = Some "docker exec {{website}}_drupal_1 stat -c '%U' /var/www/private/",
      changed_when = Some "False"
    }
  , Task::{
      name = "Change private directory owner",
      when = Some "private_directory_owner.stdout != \"www-data\"",
      command = Some "docker exec {{website}}_drupal_1 chown -R www-data:www-data /var/www/private/"
    }
  , Task::{
      name = "Check files directory owner",
      register = Some "files_directory_owner",
      command = Some "docker exec {{website}}_drupal_1 stat -c '%U' /var/www/private/",
      changed_when = Some "False"
    }
  , Task::{
      name = "Change files directory owner",
      when = Some "files_directory_owner.stdout != \"www-data\"",
      command = Some "docker exec {{website}}_drupal_1 chown -R www-data:www-data /var/www/html/sites/default/files"
    }
  , Task::{
      name = "Composer update",
      register = Some "result",
      when = Some "update | bool",
      command = Some "docker exec {{website}}_drupal_1 composer update",
      changed_when = Some "\"Package operations\" in result.stderr"
    }
  , Task::{
      name = "Update database",
      when = Some "update | bool",
      command = Some "docker exec {{website}}_drupal_1 drush updb"
    }
  , Task::{
      name = "Disable maintenance mode",
      when = Some "update | bool",
      command = Some "docker exec {{website}}_drupal_1 drush maint:set 0"
    }
  , Task::{ name = "Clear caches", command = Some "docker exec {{website}}_drupal_1 drush cr" }
]
