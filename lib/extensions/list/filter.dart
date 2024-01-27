// extending [Filter] to Stream and applying a predicate function [bool Function(T) where] that serves as a condition for each element in the stream
extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}
