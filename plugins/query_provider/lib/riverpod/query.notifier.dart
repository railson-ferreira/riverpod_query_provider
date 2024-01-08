import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/api.state.dart';

class QueryNotifier<T> extends Notifier<APIState<T>> {
  final T? initial;
  final bool shouldFetchOnMount;

  QueryNotifier(
    this.service, {
    this.initial,
    this.shouldFetchOnMount = false,
  });

  Future<T> Function(NotifierProviderRef<APIState<T>> ref) service;

  @override
  APIState<T> build() {
    if (shouldFetchOnMount) {
      Future(fetch);
    }
    return APIState<T>.idle(initial ?? stateOrNull?.data);
  }

  Future<T?> fetch({
    bool shouldThrow = false,
  }) async {
    try {
      state = APIState.loading(state.data);
      final response = await service(ref);
      state = APIState.data(response);
      return response;
    } catch (e, trace) {
      state = APIState.error(
        cache: state.data,
        error: e.toString(),
        trace: trace,
      );
      if (shouldThrow) {
        rethrow;
      }
    }
    return null;
  }
}
