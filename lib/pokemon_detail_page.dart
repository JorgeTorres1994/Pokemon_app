import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/poke_api_service.dart';

class PokemonDetailPage extends StatefulWidget {
  final int pokemonId;

  const PokemonDetailPage({super.key, required this.pokemonId});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

const Map<String, String> statTranslations = {
  'hp': 'PS',
  'attack': 'Ataque',
  'defense': 'Defensa',
  'special-attack': 'Ataque Esp.',
  'special-defense': 'Defensa Esp.',
  'speed': 'Velocidad',
};

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late Future<PokemonDetail> _pokemonDetailFuture;

  @override
  void initState() {
    super.initState();
    _pokemonDetailFuture = PokeApiService.fetchPokemonDetail(widget.pokemonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<PokemonDetail>(
        future: _pokemonDetailFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final pokemon = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Hero(
                  tag: 'pokemon-${pokemon.id}',
                  child: Image.network(pokemon.imageUrl, height: 200),
                ),
                const SizedBox(height: 12),
                Text(
                  pokemon.nameEs.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('#${pokemon.id}'),

                if (pokemon.descriptionEs != null &&
                    pokemon.descriptionEs!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      pokemon.descriptionEs!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                Wrap(
                  spacing: 10,
                  children: pokemon.types
                      .map(
                        (type) => Chip(
                          label: Text(
                            typeTranslations[type] ?? type.toUpperCase(),
                            style: const TextStyle(color: Colors.black87),
                          ),
                          backgroundColor: Colors.pink.shade100,
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('Altura'),
                        Text('${pokemon.height / 10} m'),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Peso'),
                        Text('${pokemon.weight / 10} kg'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Habilidades:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                ...pokemon.abilities.map((a) => Text('- $a')).toList(),

                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Estadísticas:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                ...pokemon.stats.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            statTranslations[entry.key.toLowerCase()] ??
                                entry.key.toUpperCase(),
                          ),

                          Text(entry.value.toString()),
                        ],
                      ),
                      LinearProgressIndicator(
                        value: entry.value / 150,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
