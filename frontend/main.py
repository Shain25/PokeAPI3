import random
from frontend.pokeapi import get_pokemon_details
from api_client import PokemonAPIClient
import os

BACKEND_URL = os.getenv('BACKEND_URL', 'http://localhost:5000')
api_client = PokemonAPIClient(BACKEND_URL)

def get_random_pokemon():
    import requests
    url = "https://pokeapi.co/api/v2/pokemon?limit=1500"
    response = requests.get(url)
    if response.status_code == 200:
        pokemon_list = response.json()["results"]
        return random.choice(pokemon_list)["name"]
    return None

def main():
    print("🎮 Pokemon Distributed Collection Game")
    print("=====================================")
    
    if not api_client.health_check():
        print("❌ Cannot connect to backend server!")
        print(f"Please make sure backend is running at: {BACKEND_URL}")
        return
    
    print("✅ Connected to backend server")
    
    while True:
        choice = input("\nDo you want to draw a Pokemon? (yes/no): ").lower().strip()
        
        if choice == "no":
            print("👋 Goodbye!")
            break
        elif choice == "yes":
            chosen_pokemon = get_random_pokemon()
            if not chosen_pokemon:
                print("❌ Error: Couldn't pick a Pokemon")
                continue
            
            print(f"\n🎯 Drawing... {chosen_pokemon}")
            
            existing_pokemon = api_client.get_pokemon_by_name(chosen_pokemon)
            
            if existing_pokemon:
                print(f"📋 Pokemon {chosen_pokemon} already exists in collection!")
                print(f"🏷️  Type: {', '.join(existing_pokemon['type'])}")
                print(f"⚡ Abilities: {', '.join(existing_pokemon['abilities'])}")
                if 'created_at' in existing_pokemon:
                    print(f"📅 Added to collection: {existing_pokemon['created_at']}")
            else:
                print(f"🔄 Downloading new info about {chosen_pokemon}...")
                new_pokemon = get_pokemon_details(chosen_pokemon)
                
                if new_pokemon:

                    if api_client.add_pokemon(new_pokemon):
                        print(f"✅ New Pokemon added to collection!")
                        print(f"🏷️  Type: {', '.join(new_pokemon['type'])}")
                        print(f"⚡ Abilities: {', '.join(new_pokemon['abilities'])}")
                    else:
                        print("❌ Error: Failed to save Pokemon to backend")
                else:
                    print("❌ Error: Couldn't download Pokemon data")
        else:
            print("Please type 'yes' or 'no'")

if __name__ == "__main__":
    main()