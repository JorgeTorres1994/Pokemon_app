import 'package:app_pokemon/pokemon_detail_page.dart';
import 'package:app_pokemon/services/poke_api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const PokeApp());
}

class PokeApp extends StatelessWidget {
  const PokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  late Future<List<PokemonBasic>> _pokemonFuture;
  List<PokemonBasic> _allPokemons = [];
  String _selectedType = 'all';

  final Map<String, String> typeNamesEs = {
    'all': 'Todos',
    'fire': 'Fuego',
    'water': 'Agua',
    'grass': 'Planta',
    'electric': 'Eléctrico',
    'psychic': 'Psíquico',
    'rock': 'Roca',
    'ground': 'Tierra',
    'bug': 'Bicho',
    'normal': 'Normal',
    'poison': 'Veneno',
    'ghost': 'Fantasma',
    'dragon': 'Dragón',
    'fighting': 'Lucha',
    'ice': 'Hielo',
    'dark': 'Siniestro',
    'steel': 'Acero',
    'fairy': 'Hada',
    'flying': 'Volador',
  };

  final Map<String, IconData> typeIcons = {
    'fire': Icons.local_fire_department,
    'water': Icons.water_drop,
    'grass': Icons.eco,
    'electric': Icons.flash_on,
    'psychic': Icons.bubble_chart,
    'rock': Icons.landscape,
    'ground': Icons.terrain,
    'bug': Icons.bug_report,
    'normal': Icons.circle,
    'poison': Icons.science,
    'ghost': Icons.nightlight,
    'dragon': Icons.whatshot,
    'fighting': Icons.fitness_center,
    'ice': Icons.ac_unit,
    'dark': Icons.dark_mode,
    'steel': Icons.settings,
    'fairy': Icons.star,
    'flying': Icons.air,
  };

  @override
  void initState() {
    super.initState();
    _pokemonFuture = PokeApiService.fetchPokemonList(limit: 1000);
    _pokemonFuture.then((value) {
      setState(() {
        _allPokemons = value;
      });
    });
  } 

  @override
  Widget build(BuildContext context) {
    final filteredPokemons = _allPokemons.where((p) {
      final matchesSearch = p.name.contains(_searchText.toLowerCase());
      final matchesType =
          _selectedType == 'all' || p.types.contains(_selectedType);
      return matchesSearch && matchesType;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('PokeApp')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar Pokémon...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: typeNamesEs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final typeKey = typeNamesEs.keys.elementAt(index);
                  final typeName = typeNamesEs[typeKey]!;
                  final isSelected = _selectedType == typeKey;

                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (typeIcons.containsKey(typeKey)) ...[
                          Icon(typeIcons[typeKey], size: 18),
                          const SizedBox(width: 4),
                        ],
                        Text(typeName),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: Colors.red.shade200,
                    backgroundColor: Colors.grey.shade200,
                    onSelected: (_) {
                      setState(() => _selectedType = typeKey);
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _pokemonFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredPokemons.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final pokemon = filteredPokemons[index];
                    final imageUrl =
                        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${pokemon.id}.png';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PokemonDetailPage(pokemonId: pokemon.id),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'pokemon-${pokemon.id}',
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  imageUrl,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  pokemon.name.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '#${pokemon.id}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
