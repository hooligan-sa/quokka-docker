from flask import Flask
app = Flask(__name__)

@app.route('/device/')
def hello_world():
    device = {
        "name": "my-dev01",
        "vendor": "cisco",
        "model": "ASR9k",
        "os": "iosxr",
        "version": "6.4.4",
        "ip": "155.232.242.1",
    }
    return device


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
