import 'dart:convert';
import 'package:http/http.dart' as http;

class PokemonBasic {
  final String name;
  final int id;
  final List<String> types;

  PokemonBasic({required this.name, required this.id, required this.types});
}

class PokemonDetail {
  final int id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final int height;
  final int weight;
  final List<String> abilities;
  final Map<String, int> stats;

  final String nameEs;
  final String? descriptionEs;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.stats,
    required this.nameEs,
    this.descriptionEs,
  });
}

const Map<String, String> typeTranslations = {
  'normal': 'Normal',
  'fire': 'Fuego',
  'water': 'Agua',
  'grass': 'Planta',
  'electric': 'Eléctrico',
  'ice': 'Hielo',
  'fighting': 'Lucha',
  'poison': 'Veneno',
  'ground': 'Tierra',
  'flying': 'Volador',
  'psychic': 'Psíquico',
  'bug': 'Bicho',
  'rock': 'Roca',
  'ghost': 'Fantasma',
  'dragon': 'Dragón',
  'dark': 'Siniestro',
  'steel': 'Acero',
  'fairy': 'Hada',
};

class PokeApiService {
  static Future<List<PokemonBasic>> fetchPokemonList({int limit = 100}) async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener la lista');
    }

    final data = jsonDecode(response.body);
    final results = data['results'] as List;

    return Future.wait(
      results.asMap().entries.map((entry) async {
        final index = entry.key;
        final item = entry.value;
        final id = index + 1;

        final detailUrl = 'https://pokeapi.co/api/v2/pokemon/$id';
        final detailRes = await http.get(Uri.parse(detailUrl));

        if (detailRes.statusCode != 200)
          throw Exception('Error al obtener detalle');

        final detailData = jsonDecode(detailRes.body);
        final types = (detailData['types'] as List)
            .map((t) => t['type']['name'] as String)
            .toList();

        return PokemonBasic(name: item['name'], id: id, types: types);
      }).toList(),
    );
  }

  static Future<PokemonDetail> fetchPokemonDetail(int id) async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$id');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('Error al obtener detalles');

    final data = jsonDecode(res.body);

    final speciesRes = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$id'),
    );
    String nameEs = data['name'];
    String? descriptionEs;

    if (speciesRes.statusCode == 200) {
      final speciesData = jsonDecode(speciesRes.body);
      final names = speciesData['names'] as List;
      final entries = speciesData['flavor_text_entries'] as List;

      // Nombre en español
      nameEs = names.firstWhere(
        (n) => n['language']['name'] == 'es',
        orElse: () => {'name': data['name']},
      )['name'];

      // Descripción en español
      final descEntry = entries.firstWhere(
        (e) => e['language']['name'] == 'es',
        orElse: () => {'flavor_text': ''},
      );
      descriptionEs = (descEntry['flavor_text'] as String?)
          ?.replaceAll('\n', ' ')
          .replaceAll('\f', ' ');
    }

    return PokemonDetail(
      id: data['id'],
      name: data['name'],
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
      nameEs: nameEs,
      descriptionEs: descriptionEs,
    );
  }
}
