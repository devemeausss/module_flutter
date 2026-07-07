part of 'template_list_bloc.dart';

class TemplateListState extends Equatable {
  final ListModel<TemplateListModel> templateListList;

  const TemplateListState({required this.templateListList});

  factory TemplateListState.empty() {
    return const TemplateListState(templateListList: ListModel());
  }

  TemplateListState copyWith({ListModel<TemplateListModel>? templateListList}) {
    return TemplateListState(
      templateListList: templateList ?? this.templateListList,
    );
  }

  @override
  List<Object?> get props => [templateListList];
}
