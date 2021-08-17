import medic.Runner;

function main() {
  var runner = new Runner();
  runner.add(new blok.ElementWidgetTest());
  runner.add(new blok.dom.HydratorTest());
  runner.run();
}