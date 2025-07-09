import 'package:flutter/material.dart';
import 'models/article_model.dart';
import 'services/article_service.dart';
import '../../core/config/responsive_text.dart';
import '../../core/utils/text_utils.dart';
import 'arcticles_detail.dart';

class ArticlesListPage extends StatefulWidget {
  final List<Article>? articles;
  final String? title;
  const ArticlesListPage({Key? key, this.articles, this.title})
    : super(key: key);

  @override
  State<ArticlesListPage> createState() => _ArticlesListPageState();
}

class _ArticlesListPageState extends State<ArticlesListPage> {
  List<Article> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.articles != null) {
      articles = widget.articles!;
      isLoading = false;
    } else {
      _loadArticles();
    }
  }

  Future<void> _loadArticles() async {
    try {
      setState(() {
        isLoading = true;
      });
      final fetchedArticles = await ArticleService.getArticles();
      setState(() {
        articles = fetchedArticles;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải bài viết: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title ?? 'Danh sách bài báo',
          style: ResponsiveText.appBarTitleStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: articles.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ArticleDetailScreen(
                                article: article.toUIMap(),
                              ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              article.mainImage,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.grey[200],
                                    child: Icon(
                                      Icons.image,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  article.tags.isNotEmpty
                                      ? article.tags.first
                                      : 'Nghiên cứu y khoa',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.teal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${article.author} • ${article.date.day}/${article.date.month}/${article.date.year}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
