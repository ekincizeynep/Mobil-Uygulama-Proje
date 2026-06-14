import '../models/movie.dart';
import '../database/database_helper.dart';
import 'package:flutter/material.dart';

class AddMovieScreen extends StatefulWidget {
  final Movie? movie;

  const AddMovieScreen({super.key, this.movie});

  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final TextEditingController titleController = TextEditingController();
  String selectedType = "Film";
  String selectedCategory = "Anime";
  bool watched = false;
  int rating = 0; // Yıldız puanı (0-5 arası)

  final List<String> categories = [
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
    if (widget.movie != null) {
      titleController.text = widget.movie!.title;
      selectedType = widget.movie!.type;
      selectedCategory = widget.movie!.category;
      watched = widget.movie!.watched;
      rating = widget.movie!.rating;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.movie != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "İçerik Düzenle" : "İçerik Ekle"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst açıklama kartı
              Card(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        isEditMode ? Icons.edit_note : Icons.add_to_photos,
                        size: 40,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          isEditMode
                              ? "İçeriğin detaylarını değiştirebilir, kategorisini güncelleyebilir veya izlendi olarak işaretleyebilirsiniz."
                              : "Listenize yeni bir dizi veya film ekleyin. Kategorisini seçerek düzenli tutun.",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // İçerik adı
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Film / Dizi Adı",
                  prefixIcon: const Icon(Icons.movie_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Film - Dizi seçimi
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                items: const [
                  DropdownMenuItem(
                    value: "Film",
                    child: Row(
                      children: [
                        Icon(Icons.local_movies_outlined, size: 20),
                        SizedBox(width: 10),
                        Text("Film"),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Dizi",
                    child: Row(
                      children: [
                        Icon(Icons.tv_outlined, size: 20),
                        SizedBox(width: 10),
                        Text("Dizi"),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Tür",
                  prefixIcon: const Icon(Icons.video_library_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Kategori seçimi
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Kategori",
                  prefixIcon: const Icon(Icons.label_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // İzlendi mi
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: CheckboxListTile(
                  value: watched,
                  title: const Text(
                    "İzlendi olarak işaretle",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text("Bu içerik 'İzlediklerim' sekmesinde görünecek"),
                  secondary: Icon(
                    watched ? Icons.check_circle : Icons.check_circle_outline,
                    color: watched ? theme.colorScheme.primary : null,
                  ),
                  activeColor: theme.colorScheme.primary,
                  checkboxShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: (value) {
                    setState(() {
                      watched = value!;
                      if (!watched) {
                        rating = 0; // İzlenmediyse yıldız puanını sıfırla
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Yıldız Puan Seçici (Yalnızca "İzlendi" seçili ise görünür)
              if (watched)
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Puanınız",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            final starIndex = index + 1;
                            return IconButton(
                              icon: Icon(
                                starIndex <= rating ? Icons.star : Icons.star_border,
                                color: starIndex <= rating ? Colors.amber : theme.colorScheme.outline,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  rating = starIndex;
                                });
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Kaydet butonu
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Lütfen geçerli bir isim giriniz"),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                      return;
                    }

                    // Güncellenmiş veya yeni Movie nesnesi
                    final movie = Movie(
                      id: isEditMode ? widget.movie!.id : null,
                      title: titleController.text.trim(),
                      type: selectedType,
                      category: selectedCategory,
                      watched: watched,
                      rating: watched ? rating : 0, // İzlenmediyse puan 0 olarak saklanır
                    );

                    if (isEditMode) {
                      // Düzenleme (Update)
                      await DatabaseHelper.instance.updateMovie(movie);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Kayıt güncellendi"),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    } else {
                      // Ekleme (Create)
                      await DatabaseHelper.instance.insertMovie(movie);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text("Kayıt eklendi"),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(isEditMode ? Icons.check : Icons.save),
                  label: Text(
                    isEditMode ? "Güncelle" : "Kaydet",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}