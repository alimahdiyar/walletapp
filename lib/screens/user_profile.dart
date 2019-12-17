import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walletapp/helper/colors.dart';
import 'package:walletapp/helper/exceptions.dart';
import 'package:walletapp/models/user_profile.dart';
import 'package:walletapp/providers/user_profile.dart';

class UserProfileScreen extends StatefulWidget {
  static const routeName = '/user-profile';

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _transactionTagsPageViewController = PageController();
  var _currentPage = 0;
  var _isInit = true;
  var _isLoading = false;
  String _networkError;
  UserProfile userProfile;

  void getUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    Provider.of<UserProfileProvider>(context)
        .fetchAndSetUserProfile()
        .then((_) {
      setState(() {
        _networkError = null;
        _isLoading = false;
      });
    }).catchError((error) {
      if (error.type == AppExceptionType.FetchDataException) {
        setState(() {
          _networkError = error.toString();
          _isLoading = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    print("bill screen didChangeDependencies");
    if (_isInit) {
      this.getUserProfile();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Widget buildTabItem(String itemText, int pageViewIndex) {
    final isSelected = _currentPage == pageViewIndex;
    return GestureDetector(
      onTap: () {
        _transactionTagsPageViewController.animateToPage(pageViewIndex,
            duration: Duration(milliseconds: 200), curve: Curves.ease);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          color: isSelected
              ? AppColors.transactionTagSelected
              : AppColors.transactionTagNotSelected,
        ),
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 15.0),
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 3.0),
        child: Text(
          itemText,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }


  Widget buildTransactionContainer(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black26,
//              offset: Offset(5,2),
            blurRadius: 5.0,
          )
        ],
        color: Colors.white,
      ),
      child: Column(
        children: <Widget>[
          Text(transaction.amount.toString() + (transaction.isIncome ? '+' : '-')),
          Text(transaction.reason)
        ],
      ),
    );
  }

  void _onPageViewChange(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("bill screen build");
    userProfile = Provider.of<UserProfileProvider>(context).userProfile;
//    print(userTableData);
    return Scaffold(
      appBar: null,
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'ذر حال بارگیری...',
                    textDirection: TextDirection.rtl,
                  ),
                  CircularProgressIndicator(),
                ],
              ),
            )
          : _networkError != null
              ? GestureDetector(
                  onTap: () => getUserProfile(),
                  child: Center(
                    child: Text(
                      'خطا در اتصال به سرور: ' +
                          _networkError +
                          'click to retry',
                    ),
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: <Widget>[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            buildTabItem("همه", 0),
                            ...userProfile.userTags
                                .asMap()
                                .map((index, userTag) => MapEntry(index,
                                    buildTabItem(userTag.title, index + 1)))
                                .values
                                .toList(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.only(top: 5.0),
                          child: PageView(
                            onPageChanged: _onPageViewChange,
                            controller: _transactionTagsPageViewController,
                            children: <Widget>[
                              CustomScrollView(
                                slivers: <Widget>[
                                  SliverList(
                                    delegate: SliverChildListDelegate([
                                      ...userProfile.allTransactions
                                          .map(
                                            (transaction) =>
                                                buildTransactionContainer(
                                                    transaction),
                                          )
                                          .toList()
                                    ]),
                                  ),
                                ],
                              ),
                              ...userProfile.userTags
                                  .asMap()
                                  .map((index, userTag) => MapEntry(
                                        index,
                                        CustomScrollView(
                                          slivers: <Widget>[
                                            SliverList(
                                              delegate:
                                                  SliverChildListDelegate([
                                                ...userProfile.userTags[index]
                                                    .userTagTransactions
                                                    .map(
                                                      (transaction) =>
                                                          buildTransactionContainer(
                                                              transaction),
                                                    )
                                                    .toList(),
                                              ]),
                                            ),
                                          ],
                                        ),
                                      ))
                                  .values
                                  .toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
