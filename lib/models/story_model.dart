class StoryModel {
  final String id;
  final String title;
  final String titleEn;
  final String emoji;
  final int level;
  final List<String> pages;
  final List<String> images;
  final List<String> keyWords;
  final List<String> keyWordsEn;
  final List<Question> questions;
  final String moral;
  final String moralEn;

  StoryModel({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.emoji,
    required this.level,
    required this.pages,
    required this.images,
    required this.keyWords,
    required this.keyWordsEn,
    required this.questions,
    required this.moral,
    required this.moralEn,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleEn: json['titleEn'] ?? '',
      emoji: json['emoji'] ?? '📖',
      level: json['level'] ?? 1,
      pages: List<String>.from(json['pages'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      keyWords: List<String>.from(json['keyWords'] ?? []),
      keyWordsEn: List<String>.from(json['keyWordsEn'] ?? []),
      questions: (json['questions'] as List?)
          ?.map((q) => Question.fromJson(q))
          .toList() ??
          [],
      moral: json['moral'] ?? '',
      moralEn: json['moralEn'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleEn': titleEn,
      'emoji': emoji,
      'level': level,
      'pages': pages,
      'images': images,
      'keyWords': keyWords,
      'keyWordsEn': keyWordsEn,
      'questions': questions.map((q) => q.toJson()).toList(),
      'moral': moral,
      'moralEn': moralEn,
    };
  }

  String getTitle(String language) {
    return language == 'ar' ? title : titleEn;
  }

  String getMoral(String language) {
    return language == 'ar' ? moral : moralEn;
  }

  int get pageCount => pages.length;

  bool isLevel(int level) => this.level == level;
}

class Question {
  final String id;
  final String question;
  final String questionEn;
  final List<String> options;
  final List<String> optionsEn;
  final int correctIndex;

  Question({
    required this.id,
    required this.question,
    required this.questionEn,
    required this.options,
    required this.optionsEn,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      questionEn: json['questionEn'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      optionsEn: List<String>.from(json['optionsEn'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'questionEn': questionEn,
      'options': options,
      'optionsEn': optionsEn,
      'correctIndex': correctIndex,
    };
  }

  String getQuestion(String language) {
    return language == 'ar' ? question : questionEn;
  }

  List<String> getOptions(String language) {
    return language == 'ar' ? options : optionsEn;
  }

  bool isCorrect(int index) => index == correctIndex;
}