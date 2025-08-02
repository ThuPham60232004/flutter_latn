import 'package:flutter/material.dart';
import 'arcticles_detail.dart';
import 'models/article_model.dart';
import 'services/article_service.dart';
import '../../core/config/responsive_text.dart';
import 'arcticles_list.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({Key? key}) : super(key: key);

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  List<Article> articles = [];
  List<Article> filteredArticles = [];
  bool isLoading = true;
  String selectedCategory = 'Tất cả';
  List<Tag> allTags = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadTags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    try {
      setState(() {
        isLoading = true;
      });

      final fetchedArticles = await ArticleService.getArticles();

      setState(() {
        articles = fetchedArticles;
        filteredArticles = fetchedArticles;
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

  Future<void> _loadTags() async {
    try {
      final tags = await ArticleService.getAllTags();
      setState(() {
        allTags = tags;
      });
    } catch (e) {}
  }

  void _filterArticles(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'Tất cả') {
        filteredArticles = articles;
      } else {
        filteredArticles =
            articles.where((article) {
              return article.tags.any(
                (tag) =>
                    tag.toLowerCase().contains(category.toLowerCase()) ||
                    category.toLowerCase().contains(tag.toLowerCase()),
              );
            }).toList();
      }
    });
  }

  void _searchArticles(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredArticles = articles;
      });
    } else {
      setState(() {
        filteredArticles =
            articles.where((article) {
              return article.title.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  article.content.toLowerCase().contains(query.toLowerCase()) ||
                  article.author.toLowerCase().contains(query.toLowerCase()) ||
                  article.tags.any(
                    (tag) => tag.toLowerCase().contains(query.toLowerCase()),
                  );
            }).toList();
      });
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
        title: Text('Bài báo', style: ResponsiveText.appBarTitleStyle),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _loadArticles,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchArticles,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tìm kiếm bài báo, tin tức mới...',
                      icon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Bài viết nổi bật',
                    style: ResponsiveText.sectionHeaderStyle,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ArticleChip(
                        label: 'Tất cả',
                        selected: selectedCategory == 'Tất cả',
                        icon: Icons.all_inclusive,
                        onTap: () => _filterArticles('Tất cả'),
                      ),
                      const SizedBox(width: 8),
                      for (final tag in allTags) ...[
                        _ArticleChip(
                          label: tag.name,
                          selected: selectedCategory == tag.name,
                          icon: Icons.label,
                          onTap: () => _filterArticles(tag.name),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                  )
                else if (filteredArticles.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy bài viết nào',
                            style: TextStyle(
                              fontSize: ResponsiveText.h2,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thử tìm kiếm với từ khóa khác',
                            style: TextStyle(
                              fontSize: ResponsiveText.bodyMedium,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bài viết xu hướng',
                        style: ResponsiveText.sectionHeaderStyle,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticlesListPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Xem tất cả',
                          style: TextStyle(color: Colors.teal, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          filteredArticles.length > 4
                              ? 4
                              : filteredArticles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index];
                        return _AnimatedArticleCard(
                          article: article.toListMap(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Divider(height: 1, thickness: 1, color: Colors.grey[200]),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bài viết liên quan',
                        style: ResponsiveText.sectionHeaderStyle,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArticlesListPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Xem tất cả',
                          style: TextStyle(color: Colors.teal, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      if (filteredArticles.isEmpty) {
                        return SizedBox();
                      }
                      final mainArticle = filteredArticles.first;
                      final mainTags = mainArticle.tags;
                      final relatedArticles =
                          filteredArticles
                              .where(
                                (article) =>
                                    article != mainArticle &&
                                    article.tags.any(
                                      (tag) => mainTags.contains(tag),
                                    ),
                              )
                              .toList();
                      if (relatedArticles.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Không có bài viết liên quan',
                                  style: TextStyle(
                                    fontSize: ResponsiveText.h2,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            relatedArticles.length > 8
                                ? 8
                                : relatedArticles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final article = relatedArticles[index];
                          return _AnimatedRelatedArticleTile(
                            article: article.toListMap(),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArticleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;

  const _ArticleChip({
    required this.label,
    this.selected = false,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: selected ? Colors.teal : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: Colors.teal, width: 2) : null,
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: Colors.teal.withOpacity(0.15),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                  : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : Colors.teal,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveText.chip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedArticleCard extends StatefulWidget {
  final Map<String, String> article;
  const _AnimatedArticleCard({required this.article});
  @override
  State<_AnimatedArticleCard> createState() => _AnimatedArticleCardState();
}

class _AnimatedArticleCardState extends State<_AnimatedArticleCard> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () async {
        final articlesState =
            context.findAncestorStateOfType<_ArticlesScreenState>();
        if (articlesState != null) {
          final article = articlesState.filteredArticles.firstWhere(
            (a) => a.title == widget.article['title'],
            orElse: () => articlesState.filteredArticles.first,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ArticleDetailScreen(article: article.toUIMap()),
            ),
          );
        }
      },
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 120),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.13),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  widget.article['image']!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.article['tag']!,
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: ResponsiveText.tag,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.article['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveText.cardTitle,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          widget.article['date']!,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: ResponsiveText.caption,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.article['readTime']!,
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: ResponsiveText.caption,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedRelatedArticleTile extends StatefulWidget {
  final Map<String, String> article;
  const _AnimatedRelatedArticleTile({required this.article});
  @override
  State<_AnimatedRelatedArticleTile> createState() =>
      _AnimatedRelatedArticleTileState();
}

class _AnimatedRelatedArticleTileState
    extends State<_AnimatedRelatedArticleTile> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () async {
        final articlesState =
            context.findAncestorStateOfType<_ArticlesScreenState>();
        if (articlesState != null) {
          final article = articlesState.filteredArticles.firstWhere(
            (a) => a.title == widget.article['title'],
            orElse: () => articlesState.filteredArticles.first,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ArticleDetailScreen(article: article.toUIMap()),
            ),
          );
        }
      },
      child: AnimatedScale(
        scale: _scale,
        duration: Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.09),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.article['image']!,
                  width: 52,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 52,
                      height: 60,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.article['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveText.cardTitle,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.article['date']!,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: ResponsiveText.caption,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
