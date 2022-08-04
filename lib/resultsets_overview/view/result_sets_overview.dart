import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testimage/resultsets_overview/bloc/result_set_viewer_bloc.dart';
import 'package:testimage/resultsets_overview/view/result_set_viewer_page.dart';

class ResultSetToolbar extends StatefulWidget {
  const ResultSetToolbar({
    Key? key,
    required this.blocs,
  }) : super(key: key);

  final List<ResultSetViewerBloc> blocs;

  @override
  State<ResultSetToolbar> createState() => _ResultSetToolbarState();
}

class _ResultSetToolbarState extends State<ResultSetToolbar> {
  late ResultSetViewerBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = widget.blocs.first;
  }

  void changeBloc(int idx) {
    setState(() {
      bloc = widget.blocs[idx];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: const ResultSetToolbarWidget(),
    );
  }
}

class ResultSetToolbarWidget extends StatelessWidget {
  const ResultSetToolbarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResultSetViewerBloc, ResultSetViewerState>(
      builder: (context, state) {
        var disable = state.status.isProceeding || state.changedCount == 0;
        return Row(
          children: [
            IconButton(
                onPressed: disable
                    ? null
                    : () => context
                        .read<ResultSetViewerBloc>()
                        .add(const ResultSetViewerSaveChanges()),
                icon: const Icon(Icons.check)),
            IconButton(
                onPressed: disable
                    ? null
                    : () => context
                        .read<ResultSetViewerBloc>()
                        .add(const ResultSetViewerRejectChanges()),
                icon: const Icon(Icons.cancel)),
            IconButton(
                onPressed: disable
                    ? null
                    : () => context
                        .read<ResultSetViewerBloc>()
                        .add(const ResultSetViewerGenerateScript()),
                icon: const Icon(Icons.code)),
          ],
        );
      },
    );
  }
}

class ResultSetsOverView extends StatefulWidget {
  const ResultSetsOverView({
    Key? key,
    required this.rsvs,
  }) : super(key: key);

  final List<ResultSetViewer> rsvs;
  @override
  State<ResultSetsOverView> createState() => _ResultSetsOverViewState();
}

class _ResultSetsOverViewState extends State<ResultSetsOverView> {
  final GlobalKey<_ResultSetToolbarState> _toolbarKey =
      GlobalKey<_ResultSetToolbarState>();
  final PageController _pageController = PageController();
  final _currentPageNotifier = ValueNotifier<int>(0);

  late final List<ResultSetViewerBloc> blocs;
  @override
  void initState() {
    super.initState();
    blocs = widget.rsvs
        .map((rsv) => ResultSetViewerBloc(resultSetViewr: rsv))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results'), actions: [
        ResultSetToolbar(
          blocs: blocs,
          key: _toolbarKey,
        )
      ]),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              itemBuilder: ((context, index) {
                return ResultSetViewerPage(
                  resultSetViewerBloc: blocs[index],
                );
              }),
              controller: _pageController,
              itemCount: blocs.length,
              onPageChanged: (int index) {
                _toolbarKey.currentState?.changeBloc(index);
                _currentPageNotifier.value = index;
              },
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 10.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentPageNotifier,
                  builder: (context, currentPos, _) {
                    return DotsIndicator(
                      dotsCount: blocs.length,
                      position: currentPos.toDouble(),
                      decorator: DotsDecorator(
                        size: const Size.square(15.0),
                        activeSize: const Size(30.0, 15.0),
                        activeShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)),
                      ),
                      onTap: (pos) {
                        _pageController.animateToPage(pos.floor(),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
