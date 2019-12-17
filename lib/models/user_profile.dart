class Transaction {
  final String reason;
  final int amount;
  final bool isIncome;

  Transaction({this.reason, this.amount, this.isIncome});


  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      reason: json['reason'],
      amount: json['amount'],
      isIncome: json['is_income'],
    );
  }
}

class UserTransactionTag {
  final String title;
  final List<Transaction> userTagTransactions;

  UserTransactionTag({this.title, this.userTagTransactions});

  factory UserTransactionTag.fromJson(Map<String, dynamic> json) {
    return UserTransactionTag(
      title: json['title'],
      userTagTransactions: (json['user_tag_transactions'] as List<dynamic>)
          .map(
            (transactionJson) => Transaction.fromJson(
              transactionJson,
        ),
      )
          .toList(),
    );
  }
}

class UserProfile {
  final List<UserTransactionTag> userTags;

  UserProfile({this.userTags});

  List<Transaction> get allTransactions {
    return [
      for (var i = 0; i < userTags.length; i++)
        ...userTags[i].userTagTransactions
    ];
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userTags: (json['user_tags'] as List<dynamic>)
          .map(
            (userTransactionTagJson) => UserTransactionTag.fromJson(
              userTransactionTagJson,
            ),
          )
          .toList(),
    );
  }
}
