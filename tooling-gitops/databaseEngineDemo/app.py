from flask import Flask
import psycopg2
import os
from dotenv import load_dotenv

app = Flask(__name__)

@app.route("/")
def index():
    load_dotenv('/vault/secrets/db.env', override=True)
    db_user = os.getenv("DB_USERNAME")
    db_pass = os.getenv("DB_PASSWORD")
    db_host = os.getenv("DB_HOST", "localhost")
    db_name = os.getenv("DB_NAME", "demo")

    conn = psycopg2.connect(
        dbname=db_name,
        user=db_user,
        password=db_pass,
        host=db_host
    )

    cur = conn.cursor()
    cur.execute("SELECT current_user;")
    current_user = cur.fetchone()[0]
    cur.close()
    conn.close()

    return f"<h1>Connected as: {current_user}</h1>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
