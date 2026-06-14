import '../database/database_helper.dart';
import '../models/movie.dart';
import '../main.dart';
import 'add_movie_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> movieList = [];
  int selectedIndex = 0;
  String searchText = '';
  String selectedCategoryFilter = "Tümü";
  final TextEditingController searchController = TextEditingController();

  final List<String> filterCategories = [
    "Tümü",
    "Anime",
    "Kore",
    "Japon",
    "Çin",
    "ABD",
    "Türk",
  ];

  @override
  void initState() {
    super.initState();
    getMovies();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> getMovies() async {
    final list = await DatabaseHelper.instance.getMovies();
    setState(() {
      movieList = list;
    });
  }

  Future<void> toggleWatched(Movie movie) async {
    // İzlenme durumunu değiştirirken, izlenmediye çekilirse puan da sıfırlanır
    final updatedMovie = Movie(
      id: movie.id,
      title: movie.title,
      type: movie.type,
      category: movie.category,
      watched: !movie.watched,
      rating: !movie.watched ? movie.rating : 0, 
    );
    await DatabaseHelper.instance.updateMovie(updatedMovie);
    getMovies();
    
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            movie.watched 
                ? "\"${movie.title}\" izleme listesine geri taşındı" 
                : "\"${movie.title}\" izlendi olarak işaretlendi",
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category.trim()) {
      case "Anime":
        return Icons.animation;
      case "Kore":
        return Icons.spa_outlined;
      case "Japon":
        return Icons.filter_hdr_outlined;
      case "Çin":
        return Icons.explore_outlined;
      case "ABD":
        return Icons.public_outlined;
      case "Türk":
        return Icons.theater_comedy_outlined;
      default:
        return Icons.movie_filter_outlined;
    }
  }

  Future<void> showDeleteDialog(BuildContext context, Movie movie) async {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 10),
              const Text("İçeriği Sil"),
            ],
          ),
          content: Text(
            "\"${movie.title}\" kaydını silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Vazgeç",
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (movie.id != null) {
                  await DatabaseHelper.instance.deleteMovie(movie.id!);
                  getMovies();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("\"${movie.title}\" silindi"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: theme.colorScheme.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text("Sil"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    int watchedCount = movieList.where((movie) => movie.watched).length;
    int watchListCount = movieList.where((movie) => !movie.watched).length;
    int totalCount = movieList.length;
    double progressPercent = totalCount > 0 ? watchedCount / totalCount : 0.0;

    final filteredList = movieList.where((movie) {
      bool matchesTab = selectedIndex == 0 ? movie.watched : !movie.watched;
      bool matchesSearch = movie.title.toLowerCase().contains(searchText);
      bool matchesCategoryFilter = selectedCategoryFilter == "Tümü" ||
          movie.category == selectedCategoryFilter;
      return matchesTab && matchesSearch && matchesCategoryFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "İzleme Listem",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              final isDark = currentMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                tooltip: isDark ? "Açık Tema" : "Koyu Tema",
                onPressed: () {
                  themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMovieScreen(),
            ),
          );
          getMovies();
        },
        icon: const Icon(Icons.add),
        label: const Text("Ekle"),
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Film veya dizi ara...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchText = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

          // Kategori Hızlı Filtre Çipleri (Yatay Kaydırılabilir)
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filterCategories.length,
              itemBuilder: (context, index) {
                final cat = filterCategories[index];
                final isSelected = selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategoryFilter = selected ? cat : "Tümü";
                      });
                    },
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),

          // İstatistik Kartları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Icon(Icons.dashboard_customize_outlined, 
                              color: theme.colorScheme.secondary, size: 20),
                          const SizedBox(height: 4),
                          const Text("Toplam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text("$totalCount", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, 
                              color: theme.colorScheme.primary, size: 20),
                          const SizedBox(height: 4),
                          const Text("İzlendi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text("$watchedCount", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Icon(Icons.bookmark_border, 
                              color: theme.colorScheme.tertiary, size: 20),
                          const SizedBox(height: 4),
                          const Text("Listem", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text("$watchListCount", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // İlerleme Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "İzleme Oranı",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      "%${(progressPercent * 100).toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Liste Görünümü / Boş Liste Durumu
          filteredList.isEmpty
              ? Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedIndex == 0
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.bookmark_outline_rounded,
                              size: 80,
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchText.isNotEmpty || selectedCategoryFilter != "Tümü"
                                  ? "Aradığınız kriterde içerik bulunamadı."
                                  : (selectedIndex == 0
                                      ? "Henüz izlenmiş bir içerik yok.\nTamamladığınız filmleri burada göreceksiniz!"
                                      : "İzleme listeniz şu an boş.\nYeni içerik eklemek için aşağıdaki '+' butonunu kullanın!"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final movie = filteredList[index];

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withValues(alpha: 0.08),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            // Karta tıklayınca Düzenleme Ekranı açılır
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddMovieScreen(movie: movie),
                              ),
                            );
                            getMovies();
                          },
                          onLongPress: () {
                            // Uzun basınca Silme Onay Penceresi açılır
                            showDeleteDialog(context, movie);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Durum Değiştirme Butonu (Check / Bookmark)
                                GestureDetector(
                                  onTap: () => toggleWatched(movie),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: movie.watched
                                          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                                          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      movie.watched ? Icons.check_circle : Icons.bookmark_border,
                                      color: movie.watched
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Film/Dizi Başlığı, Yıldız Puanı ve Etiketleri
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        movie.title,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      
                                      // Eğer İzlendi ise ve Puan Verildiyse Yıldızları Göster
                                      if (movie.watched && movie.rating > 0) ...[
                                        const SizedBox(height: 3),
                                        Row(
                                          children: List.generate(5, (starIndex) {
                                            return Icon(
                                              starIndex < movie.rating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              size: 14,
                                              color: starIndex < movie.rating
                                                  ? Colors.amber
                                                  : theme.colorScheme.outline.withValues(alpha: 0.3),
                                            );
                                          }),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      
                                      Row(
                                        children: [
                                          // Tür Etiketi (Film / Dizi)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  movie.type == "Film"
                                                      ? Icons.local_movies_outlined
                                                      : Icons.tv_outlined,
                                                  size: 12,
                                                  color: theme.colorScheme.onSecondaryContainer,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  movie.type,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.onSecondaryContainer,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          // Kategori Etiketi (İkon + Kategori İsmi)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  getCategoryIcon(movie.category),
                                                  size: 12,
                                                  color: theme.colorScheme.onTertiaryContainer,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  movie.category,
                                                  style: theme.textTheme.bodySmall?.copyWith(
                                                    color: theme.colorScheme.onTertiaryContainer,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Silme İkon Butonu
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error.withValues(alpha: 0.8),
                                  ),
                                  onPressed: () {
                                    showDeleteDialog(context, movie);
                                  },
                                  tooltip: "Sil",
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            activeIcon: Icon(Icons.check_circle),
            label: "İzlediklerim",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: "Listem",
          ),
        ],
      ),
    );
  }
}