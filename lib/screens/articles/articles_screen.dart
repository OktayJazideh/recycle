import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/app_data_service.dart';
import '../../models/rating_model.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = AppDataService().articles.where((a) => a.isPublished).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('مقالات آموزشی')),
      body: articles.isEmpty
        ? const Center(child: Text('مقاله\u200cای وجود ندارد', style: TextStyle(color: AppColors.textSecondary)))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: articles.length,
            itemBuilder: (_, i) => _articleCard(context, articles[i]),
          ),
    );
  }

  Widget _articleCard(BuildContext context, ArticleModel article) {
    final catIcons = {'pricing': Icons.monetization_on, 'education': Icons.school, 'safety': Icons.health_and_safety, 'economics': Icons.trending_up, 'tips': Icons.lightbulb};
    final catColors = {'pricing': AppColors.primaryGreen, 'education': AppColors.blue, 'safety': AppColors.red, 'economics': AppColors.orange, 'tips': AppColors.gold};

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ArticleDetailScreen(article: article))),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: (catColors[article.category] ?? AppColors.primaryGreen).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(catIcons[article.category] ?? Icons.article, color: catColors[article.category] ?? AppColors.primaryGreen, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(article.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.visibility, size: 14, color: AppColors.textSecondary),
                Text(' ${article.views}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Icon(Icons.favorite, size: 14, color: AppColors.red),
                Text(' ${article.likes}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(width: 12),
                Text(article.author, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ])),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.divider),
          ]),
        ),
      ),
    );
  }
}

class _ArticleDetailScreen extends StatelessWidget {
  final ArticleModel article;
  const _ArticleDetailScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مقاله')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity, height: 160,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryGreen, AppColors.lightGreen]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: Icon(Icons.article, size: 56, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          Text(article.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
            Text(' ${article.author}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(width: 16),
            const Icon(Icons.visibility, size: 16, color: AppColors.textSecondary),
            Text(' ${article.views} بازدید', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          Text(article.content, style: const TextStyle(fontSize: 15, height: 1.8)),
        ]),
      ),
    );
  }
}
