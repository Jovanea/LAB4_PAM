/// O eroare explicata pe intelesul utilizatorului (fara detalii tehnice).
///
/// Stratul Data transforma orice problema (fara internet, server picat,
/// JSON gresit) intr-un [Failure], iar interfata doar afiseaza [message].
class Failure implements Exception {
  const Failure(this.message);

  final String message;

  @override
  String toString() => message;
}
