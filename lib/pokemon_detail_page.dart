
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/poke_api_service.dart';

class PokemonDetailPage extends StatefulWidget {
  final int pokemonId;

  const PokemonDetailPage({super.key, required this.pokemonId});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

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
                const SizedBox(height: 16),

                Wrap(
                  spacing: 10,
                  children: pokemon.types
                      .map(
                        (type) => Chip(
                          label: Text(type.toUpperCase()),
                          backgroundColor: Colors.red.shade100,
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
                          Text(entry.key.toUpperCase()),
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

                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Cadena evolutiva:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: pokemon.evolutionChain.map((evo) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            Image.network(evo.imageUrl, height: 80),
                            const SizedBox(height: 8),
                            Text(
                              evo.name.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
