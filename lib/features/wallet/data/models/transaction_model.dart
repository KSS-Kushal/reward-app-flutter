import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.status,
    required super.source,
    required super.createdAt,
    super.description,
    super.reference,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json.readString('id'),
        title: json.readString('title'),
        description: json.readStringOrNull('description'),
        amount: json.readInt('amount').abs(),
        type: json.readEnum(
          'type',
          TransactionType.values,
          TransactionType.credit,
        ),
        status: json.readEnum(
          'status',
          TransactionStatus.values,
          TransactionStatus.completed,
        ),
        source: json.readEnum(
          'source',
          TransactionSource.values,
          TransactionSource.bonus,
        ),
        createdAt: json.readDateTime('createdAt'),
        reference: json.readStringOrNull('reference'),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'amount': amount,
    'type': type.name,
    'status': status.name,
    'source': source.name,
    'createdAt': createdAt.toIso8601String(),
    'reference': reference,
  };
}
