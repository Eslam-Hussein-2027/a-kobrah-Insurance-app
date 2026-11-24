import '../../shared/ui.dart';
import 'request_models.dart';

StatusTone requestTone(RequestStatus status) => switch (status) {
  RequestStatus.submitted || RequestStatus.inReview => StatusTone.info,
  RequestStatus.quoted => StatusTone.warning,
  RequestStatus.completed => StatusTone.success,
  RequestStatus.rejected => StatusTone.danger,
  RequestStatus.cancelled => StatusTone.neutral,
};
