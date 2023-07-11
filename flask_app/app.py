from flask import Flask
app = Flask(__name__)
@app.route("/")
def hello():
    return "Yayy, we have the 2st version of our flask application (Microservice)"
if __name__ == "__main__":
    app.run(host="0.0.0.0")