import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def SayHello():
    return f"{os.environ.get('MSG')}"

if __name__ == '__main___':
    app.run(debug=True, port=5000, host='0.0.0.0')

