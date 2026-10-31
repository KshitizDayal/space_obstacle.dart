enum WaveEvent {
  meteorShower('METEOR SHOWER!'),
  chasers('ASTEROIDS INCOMING!'),
  blackHole('BLACK HOLE!');

  const WaveEvent(this.title);

  final String title;
}
