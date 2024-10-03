import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class BusinessLogic {
  void toggle<TKey, TValue>(
      Map<TKey, TValue> map, TKey key, TValue defaultValue) {
    if (map.containsKey(key)) {
      map.remove(key);
    } else {
      map[key] = defaultValue;
    }
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  Map<WordPair, bool> favorites = {};

  void toggleFavorite(WordPair pair) {
    BusinessLogic().toggle(favorites, pair, false);
    notifyListeners();
  }

  void toggleIcon(bool remove, WordPair pair) {
    favorites[pair] = remove;
    // favorites.update(key, (value) => !value, ifAbsent: () => false)
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page = switch (selectedIndex) {
      0 => GeneratorPage(),
      1 => FavoritesPage(),
      _ => throw UnimplementedError('no widget for $selectedIndex')
    };

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  print('selected: $value');
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var favoriteIcon = appState.favorites.containsKey(pair)
        ? Icons.favorite
        : Icons.favorite_border;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: Icon(favoriteIcon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;

    return Center(
      child: ListView(
        children: favorites.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('No favorites yet.'),
                )
              ]
            : [
                for (var entry in favorites.entries)
                  ListTile(
                    leading: ElevatedButton.icon(
                      onPressed: () {
                        print('toggle ${entry.key.asLowerCase}.');
                        appState.toggleFavorite(entry.key);
                      },
                      icon: Icon(entry.value ? Icons.delete : Icons.favorite),
                      label: Text(entry.key.asLowerCase),
                      onHover: (entered) {
                        print('${entry.key.asLowerCase} hover $entered');
                        appState.toggleIcon(entered, entry.key);
                      },
                    ),
                  )
              ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
