import typer
from support_sphere.scripts.execute_sql_statement import execute_sql_app
from support_sphere.scripts.update_db_sample_data import db_init_app

# The parent app that will contain all child apps for different script types
app = typer.Typer()

app.add_typer(execute_sql_app, name="execute_sql")
app.add_typer(db_init_app, name="db_init")

if __name__ == "__main__":
    app()
