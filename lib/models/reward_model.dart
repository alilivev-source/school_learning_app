/// نموذج بيانات يمثّل مكافأة/ملصق في متجر المكافآت
class RewardModel {
  final String id;
  final String name;
  final String nameEn;
  final String emoji;
  final int price;
  final String category;
  bool isUnlocked;

  RewardModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.emoji,
    required this.price,
    this.category = 'stickers',
    this.isUnlocked = false,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['nameEn'] ?? '',
      emoji: json['emoji'] ?? '🏆',
      price: json['price'] ?? 10,
      category: json['category'] ?? 'stickers',
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'emoji': emoji,
      'price': price,
      'category': category,
      'isUnlocked': isUnlocked,
    };
  }

  /// قائمة الملصقات الافتراضية المتاحة في المتجر
  static List<RewardModel> defaultRewards() {
    const items = [
      ['sticker_star', 'نجمة ذهبية', 'Gold Star', '⭐', 10],
      ['sticker_trophy', 'كأس البطل', 'Champion Cup', '🏆', 20],
      ['sticker_rainbow', 'قوس قزح', 'Rainbow', '🌈', 15],
      ['sticker_rocket', 'صاروخ', 'Rocket', '🚀', 25],
      ['sticker_crown', 'تاج ملكي', 'Royal Crown', '👑', 30],
      ['sticker_heart', 'قلب متلألئ', 'Sparkling Heart', '💖', 10],
      ['sticker_medal', 'ميدالية', 'Medal', '🥇', 20],
      ['sticker_balloon', 'بالون احتفال', 'Party Balloon', '🎈', 12],
    ];
    return items
        .map((e) => RewardModel(
              id: e[0] as String,
              name: e[1] as String,
              nameEn: e[2] as String,
              emoji: e[3] as String,
              price: e[4] as int,
            ))
        .toList();
  }
}
