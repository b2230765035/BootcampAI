abstract class UseCase<Type, Params> {
  Future<Type> call({required Params param});
}

abstract class UseCase2<Type, Param1, Param2> {
  Future<Type> call({required Param1 param1, required Param2 param2});
}

abstract class UseCase3<Type, Param1, Param2, Param3> {
  Future<Type> call({
    required Param1 param1,
    required Param2 param2,
    required Param2 param3,
  });
}
