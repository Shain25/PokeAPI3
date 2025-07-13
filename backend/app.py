<<<<<<< HEAD
from flask import Flask, request, jsonify
from backend.dynamodb_manager import load_pokemon, save_data, get_pokemon_by_name, create_table_if_not_exists
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

create_table_if_not_exists()

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'service': 'pokeapi-backend'})

@app.route('/pokemon', methods=['GET'])
def get_all_pokemon():

    try:
        result = load_pokemon()
        return jsonify(result)
    except Exception as e:
        logging.error(f"Error loading pokemon: {e}")
        return jsonify({'error': 'Failed to load pokemon'}), 500

@app.route('/pokemon/<name>', methods=['GET'])
def get_pokemon(name):

    try:
        pokemon = get_pokemon_by_name(name.lower())
        if pokemon:
            return jsonify(pokemon)
        else:
            return jsonify({'error': 'Pokemon not found'}), 404
    except Exception as e:
        logging.error(f"Error getting pokemon {name}: {e}")
        return jsonify({'error': 'Failed to get pokemon'}), 500

@app.route('/pokemon', methods=['POST'])
def add_pokemon():

    try:
        pokemon_data = request.json
        
        if 'name' not in pokemon_data:
            return jsonify({'error': 'Pokemon name is required'}), 400
        
        existing = get_pokemon_by_name(pokemon_data['name'].lower())
        if existing:
            return jsonify({'error': 'Pokemon already exists'}), 409
        
        save_data(pokemon_data)
        return jsonify({'message': 'Pokemon added successfully', 'name': pokemon_data['name']}), 201
        
    except Exception as e:
        logging.error(f"Error adding pokemon: {e}")
        return jsonify({'error': 'Failed to add pokemon'}), 500

@app.route('/pokemon/<name>', methods=['PUT'])
def update_pokemon(name):
    try:
        pokemon_data = request.json
        
        existing = get_pokemon_by_name(name.lower())
        if not existing:
            return jsonify({'error': 'Pokemon not found'}), 404
        
        pokemon_data['name'] = name.lower()
        save_data(pokemon_data)
        
        return jsonify({'message': 'Pokemon updated successfully', 'name': name})
        
    except Exception as e:
        logging.error(f"Error updating pokemon {name}: {e}")
        return jsonify({'error': 'Failed to update pokemon'}), 500

@app.route('/pokemon/<name>', methods=['DELETE'])
def delete_pokemon(name):
    """מוחק פוקימון (לא מומש במנהל DynamoDB הנוכחי)"""
    return jsonify({'error': 'Delete operation not implemented yet'}), 501

if __name__ == '__main__':
=======
from flask import Flask, request, jsonify
from backend.dynamodb_manager import load_pokemon, save_data, get_pokemon_by_name, create_table_if_not_exists
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

create_table_if_not_exists()

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'service': 'pokeapi-backend'})

@app.route('/pokemon', methods=['GET'])
def get_all_pokemon():

    try:
        result = load_pokemon()
        return jsonify(result)
    except Exception as e:
        logging.error(f"Error loading pokemon: {e}")
        return jsonify({'error': 'Failed to load pokemon'}), 500

@app.route('/pokemon/<name>', methods=['GET'])
def get_pokemon(name):

    try:
        pokemon = get_pokemon_by_name(name.lower())
        if pokemon:
            return jsonify(pokemon)
        else:
            return jsonify({'error': 'Pokemon not found'}), 404
    except Exception as e:
        logging.error(f"Error getting pokemon {name}: {e}")
        return jsonify({'error': 'Failed to get pokemon'}), 500

@app.route('/pokemon', methods=['POST'])
def add_pokemon():

    try:
        pokemon_data = request.json
        
        if 'name' not in pokemon_data:
            return jsonify({'error': 'Pokemon name is required'}), 400
        
        existing = get_pokemon_by_name(pokemon_data['name'].lower())
        if existing:
            return jsonify({'error': 'Pokemon already exists'}), 409
        
        save_data(pokemon_data)
        return jsonify({'message': 'Pokemon added successfully', 'name': pokemon_data['name']}), 201
        
    except Exception as e:
        logging.error(f"Error adding pokemon: {e}")
        return jsonify({'error': 'Failed to add pokemon'}), 500

@app.route('/pokemon/<name>', methods=['PUT'])
def update_pokemon(name):
    try:
        pokemon_data = request.json
        
        existing = get_pokemon_by_name(name.lower())
        if not existing:
            return jsonify({'error': 'Pokemon not found'}), 404
        
        pokemon_data['name'] = name.lower()
        save_data(pokemon_data)
        
        return jsonify({'message': 'Pokemon updated successfully', 'name': name})
        
    except Exception as e:
        logging.error(f"Error updating pokemon {name}: {e}")
        return jsonify({'error': 'Failed to update pokemon'}), 500

@app.route('/pokemon/<name>', methods=['DELETE'])
def delete_pokemon(name):
    """מוחק פוקימון (לא מומש במנהל DynamoDB הנוכחי)"""
    return jsonify({'error': 'Delete operation not implemented yet'}), 501

if __name__ == '__main__':
>>>>>>> 65e20a5 (Initial commit)
    app.run(host='0.0.0.0', port=5000, debug=True)