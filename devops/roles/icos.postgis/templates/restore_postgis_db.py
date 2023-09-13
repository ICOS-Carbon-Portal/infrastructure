#!/usr/bin/python3
import click
from restore_postgresql import restore_postgresql

@click.command('restore_rdflog_db', help=f'Restore latest rdflog backup')
@click.option('--host', type=click.STRING)
@click.option('--location', type=click.STRING)
def restore_postgis_db(host, location):
    restore_postgresql(host, location, "postgis", "postgres", ignore_role_stmts = 1)

if __name__ == '__main__':
    restore_postgis_db()
