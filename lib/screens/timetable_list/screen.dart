// FutureBuilder<List<Group>>(
//        future: _bookmarksFuture,
//        builder: (context, snapshot) {
//          Widget _getDrawerHeader() => DrawerHeader(child: Text('ATH Plan'));
//
//          if (snapshot.hasData) {
//            if (snapshot.data.length == 0) {
//              return Drawer(
//                child: ListView(
//                  children: <Widget>[
//                    _getDrawerHeader(),
//                    ListTile(
//                      title: Text('Brak zakładek'),
//                      subtitle: Text('Przytrzymaj na danej grupie, aby dodać do zakładek'),
//                    )
//                  ],
//                )
//              );
//            }
//            return Drawer(
//              child: ListView.builder(
//                itemCount: snapshot.data.length + 1,
//                itemBuilder: (BuildContext _, int index) {
//                  if (index == 0) {
//                    return _getDrawerHeader();
//                  }
//                  return _getBookmarksTile(snapshot.data[index - 1], index - 1);
//                }
//              ),
//            );
//          } else if (snapshot.hasError) {
//            return Drawer(
//              child: ListView(
//                children: <Widget>[
//                  _getDrawerHeader()
//                ],
//              )
//            );
//          }
//          return Drawer(
//            child: ListView(
//              children: <Widget>[
//                _getDrawerHeader(),
//                Center(child: CircularProgressIndicator())
//              ],
//            )
//          );
//        }, //_getNavDrawer(context),
//      ),