import secrets
import os
from flask import Flask, jsonify
from flask_cors import CORS
from app.models import db
from app.routes import auth_bp, modules_bp
from flask_jwt_extended import JWTManager
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)

app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', secrets.token_hex(16))
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('SQLALCHEMY_DATABASE_URI')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

jwt = JWTManager(app)
CORS(app)
db.init_app(app)

# Регистрация blueprint для аутентификации
app.register_blueprint(auth_bp, url_prefix='/auth')
app.register_blueprint(modules_bp, url_prefix='/modules')

# Главная страница
@app.route('/')
def index():
    return jsonify({"message": "Server is running"}), 200

@app.route('/favicon.ico')
def favicon():
    return '', 204

if __name__ == '__main__':
    app.run(debug=True)
