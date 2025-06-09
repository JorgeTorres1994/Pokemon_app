import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonBasic {
  final int id;
  final String name;
  final List<String> types;

  PokemonBasic({required this.id, required this.name, required this.types});
}

class EvolutionStage {
  final int id;
  final String name;
  final String imageUrl;

  EvolutionStage({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

class PokemonDetail {
  final int id;
  final String name;
  final String nameEs;
  final String descriptionEs;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;
  final List<String> abilities;
  final Map<String, int> stats;
  final List<EvolutionStage> evolutionChain;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.nameEs,
    required this.descriptionEs,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
    required this.evolutionChain,
  });
}

class PokeApiService {
  static Future<List<PokemonBasic>> fetchPokemonList() async {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1000'),
    );
    final data = jsonDecode(response.body);

    List<PokemonBasic> pokemons = [];

    // Limitar a 151 y evitar saturación con delay
    for (var i = 0; i < 151; i++) {
      final result = data['results'][i];
      final url = result['url'] as String;
      final id = int.parse(url.split('/')[url.split('/').length - 2]);

      final detailRes = await http.get(Uri.parse(url));
      final detail = jsonDecode(detailRes.body);

      final types = (detail['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList();

      pokemons.add(PokemonBasic(id: id, name: result['name'], types: types));

      await Future.delayed(const Duration(milliseconds: 50)); // para no saturar
    }

    return pokemons;
  }

  static Future<PokemonDetail> fetchPokemonDetail(int id) async {
    final res = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'),
    );
    final data = jsonDecode(res.body);

    final speciesRes = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$id'),
    );
    final speciesData = jsonDecode(speciesRes.body);

    final nameEs = (speciesData['names'] as List).firstWhere(
      (n) => n['language']['name'] == 'es',
    )['name'];

    final descriptionEs = (speciesData['flavor_text_entries'] as List)
        .firstWhere(
          (entry) => entry['language']['name'] == 'es',
          orElse: () => {},
        )['flavor_text'];

    final evolutionUrl = speciesData['evolution_chain']['url'];
    final evoRes = await http.get(Uri.parse(evolutionUrl));
    final evoData = jsonDecode(evoRes.body);

    List<EvolutionStage> evolutionChain = [];

    void extractChain(Map<String, dynamic> chain) {
      final name = chain['species']['name'];
      final url = chain['species']['url'];
      final parts = url.split('/');
      final id = int.parse(parts[parts.length - 2]);
      final imageUrl =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

      evolutionChain.add(
        EvolutionStage(id: id, name: name, imageUrl: imageUrl),
      );

      if (chain['evolves_to'] != null && chain['evolves_to'].isNotEmpty) {
        extractChain(chain['evolves_to'][0]);
      }
    }

    extractChain(evoData['chain']);

    return PokemonDetail(
      id: data['id'],
      name: data['name'],
      nameEs: nameEs,
      descriptionEs: descriptionEs,
      imageUrl: data['sprites']['other']['official-artwork']['front_default'],
      types: (data['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList(),
      height: data['height'],
      weight: data['weight'],
      abilities: (data['abilities'] as List)
          .map((a) => a['ability']['name'] as String)
          .toList(),
      stats: Map.fromEntries(
        (data['stats'] as List).map(
          (s) => MapEntry(s['stat']['name'], s['base_stat']),
        ),
      ),
      evolutionChain: evolutionChain,
    );
  }
}
