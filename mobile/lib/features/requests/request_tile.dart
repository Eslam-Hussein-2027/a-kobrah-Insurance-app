import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../shared/widgets.dart';
import 'request_models.dart';
import 'request_status.dart';

/// Row in "My insurance → Requests".
class RequestTile extends StatelessWidget {
  const RequestTile({super.key, required this.request, required this.icon});

  final InsuranceRequest request;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/requests/${request.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBox(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          request.productName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      StatusPill(label: request.statusLabel, tone: requestTone(request.status)),
                    ],
                  ),
                  Text(
                    [request.kindLabel, if (request.summary.isNotEmpty) request.summary].join(' · '),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF3D4155)),
                  ),
                  Text(
                    '${request.requestNo} · ${formatDate(context, request.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.subtle),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
