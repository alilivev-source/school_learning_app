/// الحالة العامة الحالية للّعبة، تتحكم في الواجهة (HUD) والـ Overlays المعروضة.
enum GameStatus {
  playing,
  transitioning, // أثناء تأثير الانتقال بين مرحلة وأخرى (البوابة)
  paused,
  lost,
  levelCompleteSummary, // شاشة ملخص قصيرة بين المراحل (اختياري لعرض النقاط)
  gameCompleted, // أنهى اللاعب كل المراحل الـ100
}
