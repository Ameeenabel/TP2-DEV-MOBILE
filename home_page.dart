import 'package:flutter/material.dart';
import 'profile.page.dart';
import 'add.show.page.dart';
import 'update.show.page.dart';

// Modèle de données (à adapter à votre structure réelle)
class Show {
  final String id;
  final String title;
  final String category; // 'film', 'anime' ou 'serie'

  Show({required this.id, required this.title, required this.category});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  List<Show> shows = []; // Liste des shows (remplie via _rafraichirDonnees())

  // Catégories correspondant aux onglets
  final List<String> _categories = ['film', 'anime', 'serie'];

  @override
  void initState() {
    super.initState();
    _rafraichirDonnees(); // Chargement initial
  }

  Widget _buildPageContent(String category) {
    final filteredShows = shows.where((show) => show.category == category).toList();

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _rafraichirDonnees,
      child: filteredShows.isEmpty
          ? const Center(child: Text("Aucun show disponible"))
          : ListView.builder(
        itemCount: filteredShows.length,
        itemBuilder: (context, index) {
          final show = filteredShows[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              title: Text(show.title),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _modifierShow(context, show),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _rafraichirDonnees() async {
    // Simulation : remplacez par un appel API/BDD réel
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      shows = [
        Show(id: '1', title: 'Interstellar', category: 'film'),
        Show(id: '2', title: 'Attack on Titan', category: 'anime'),
        Show(id: '3', title: 'Breaking Bad', category: 'serie'),
      ];
    });
  }

  Future<void> _modifierShow(BuildContext context, Show show) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateShowPage(show: show, showData: {},),
      ),
    );

    if (result == true) {
      await _rafraichirDonnees(); // Rafraîchit si modification réussie
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Show modifié avec succès !")),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: const Text("Profil"),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
                _rafraichirDonnees();
              },
            ),
            ListTile(
              title: const Text("Ajouter un show"),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddShowPage()),
                );
                if (result == true) {
                  await _rafraichirDonnees();
                }
              },
            ),
          ],
        ),
      ),
      body: _buildPageContent(_categories[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: "Films",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.animation),
            label: "Animes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: "Séries",
          ),
        ],
      ),
    );
  }
}
