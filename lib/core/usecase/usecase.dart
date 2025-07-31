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

abstract class UseCase4<Type, Param1, Param2, Param3, Param4> {
  Future<Type> call({
    required Param1 param1,
    required Param2 param2,
    required Param3 param3,
    required Param4 param4,
  });
}

abstract class UseCase5<Type, Param1, Param2, Param3, Param4, Param5> {
  Future<Type> call({
    required Param1 param1,
    required Param2 param2,
    required Param3 param3,
    required Param4 param4,
    required Param5 param5,
  });
}

abstract class UseCase6<Type, Param1, Param2, Param3, Param4, Param5, Param6> {
  Future<Type> call({
    required Param1 param1,
    required Param2 param2,
    required Param3 param3,
    required Param4 param4,
    required Param5 param5,
    required Param6 param6,
  });
}
