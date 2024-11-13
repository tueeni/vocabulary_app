from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, get_jwt_identity, jwt_required
from app.models import db, User, Module, Term

auth_bp = Blueprint('auth', __name__)
modules_bp = Blueprint('modules', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if User.query.filter_by(email=email).first():
        return jsonify({'error': 'Email уже зарегистрирован'}), 400

    user = User(email=email)
    user.set_password(password)
    db.session.add(user)
    db.session.commit()

    return jsonify({'message': 'Регистрация успешна'}), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    user = User.query.filter_by(email=email).first()
    if user and user.check_password(password):
        access_token = create_access_token(identity=user.id)  
        return jsonify({'token': access_token, 'message': 'Успешный вход'}), 200
    else:
        return jsonify({'error': 'Неверный email или пароль'}), 400
    
@auth_bp.route('/logout', methods=['POST'])
def logout():
    return jsonify({'message': 'Успешный выход'}), 200

@modules_bp.route('/my-modules', methods=['GET'])
@jwt_required()
def get_my_modules():
    user_id = get_jwt_identity()  # Получаем ID текущего пользователя
    modules = Module.query.filter_by(creator_id=user_id).all()
    
    modules_data = [{'id': module.id, 'title': module.title, 'description': module.description} for module in modules]
    return jsonify(modules_data), 200

@modules_bp.route('/create', methods=['POST'])
@jwt_required()
def create_module_with_terms():
    data = request.get_json()
    title = data.get('title')
    description = data.get('description')
    terms = data.get('terms')  # Список словарей с терминами [{'term_name': '...', 'definition': '...'}, ...]

    if not title or not description:
        return jsonify({'error': 'Название и описание обязательны'}), 400

    user_id = get_jwt_identity()

    new_module = Module(title=title, description=description, creator_id=user_id)
    db.session.add(new_module)
    db.session.flush() 

    if terms:
        for term_data in terms:
            term_name = term_data.get('term_name')
            definition = term_data.get('definition')

            if term_name and definition:
                new_term = Term(term_name=term_name, definition=definition, module_id=new_module.id)
                db.session.add(new_term)

    db.session.commit()

    return jsonify({'message': 'Модуль и термины успешно созданы', 'module_id': new_module.id}), 201


@modules_bp.route('/module/<int:module_id>', methods=['GET'])
@jwt_required()
def get_module_details(module_id):
    user_id = get_jwt_identity()
    module = Module.query.filter_by(id=module_id, creator_id=user_id).first()

    if not module:
        return jsonify({'error': 'Модуль не найден или доступ запрещен'}), 404

    terms = Term.query.filter_by(module_id=module.id).all()
    terms_data = [{'term_name': term.term_name, 'definition': term.definition} for term in terms]

    module_data = {
        'id': module.id,
        'title': module.title,
        'description': module.description,
        'terms': terms_data
    }
    return jsonify(module_data), 200

@modules_bp.route('/<int:module_id>/update_module', methods=['PUT'])
@jwt_required()
def update_module_info(module_id):
    user_id = get_jwt_identity()
    module = Module.query.filter_by(id=module_id, creator_id=user_id).first()
    if not module:
        return jsonify({"error": "Модуль не найден или доступ запрещен"}), 404
    
    data = request.json
    title = data.get('title')
    description = data.get('description')

    if not title or not description:
        return jsonify({"error": "Название и описание обязательны"}), 400

    module.title = title
    module.description = description
    db.session.commit()

    return jsonify({"message": "Информация о модуле успешно обновлена"}), 200

@modules_bp.route('/<int:module_id>/update_terms', methods=['PUT'])
@jwt_required()
def update_module_terms(module_id):
    data = request.json
    terms = data.get('terms', [])

    existing_terms = {term.term_id: term for term in Term.query.filter_by(module_id=module_id).all()}

    for term_data in terms:
        term_id = term_data.get('term_id')
        term_name = term_data.get('term_name')
        definition = term_data.get('definition')

        if term_id in existing_terms:
            # Обновляем существующий термин
            term = existing_terms[term_id]
            term.term_name = term_name
            term.definition = definition
            del existing_terms[term_id]
        else:
            new_term = Term(module_id=module_id, term_name=term_name, definition=definition)
            db.session.add(new_term)

    # Удаляем термины, которые не были переданы
    for term in existing_terms.values():
        db.session.delete(term)

    db.session.commit()
    return jsonify({"message": "Terms updated successfully"}), 200

@modules_bp.route('/<int:module_id>/terms/<int:term_id>', methods=['DELETE'])
@jwt_required()
def delete_term(module_id, term_id):
    user_id = get_jwt_identity()
    module = Module.query.filter_by(id=module_id, creator_id=user_id).first()
    if module is None:
        return jsonify({'message': 'Модуль не найден или не принадлежит пользователю'}), 404

    term = Term.query.filter_by(id=term_id, module_id=module_id).first()
    if term is None:
        return jsonify({'message': 'Термин не найден'}), 404

    db.session.delete(term)
    db.session.commit()

    return jsonify({'message': 'Термин успешно удален'}), 200

@modules_bp.route('/<int:module_id>/terms', methods=['GET'])
@jwt_required()
def get_terms(module_id):
    print(f"Requested module_id: {module_id}") 
    module = Module.query.get(module_id)
    if not module:
        print(f"Module with id {module_id} not found")
        return jsonify({"error": "Module not found"}), 404

    terms = Term.query.filter_by(module_id=module_id).all()
    terms_data = [{"term": term.term_name, "definition": term.definition} for term in terms]

    return jsonify(terms_data), 200