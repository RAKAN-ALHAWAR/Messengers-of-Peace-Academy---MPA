part of '../../widget.dart';

class AddParentX extends StatelessWidget {
  const AddParentX({
    required this.child,
    required this.parent,
    this.isAdd = true,
    super.key,
  });
  final Widget Function(Widget child) parent;
  final Widget child;
  final bool isAdd;

  @override
  Widget build(BuildContext context) {
    return isAdd ? parent(child) : child;
  }
}

extension AddParentExtensionX on Widget {
  Widget addParentX(Widget Function(Widget child)? parent,{bool condition = true}) {
    if(parent!=null){
      return AddParentX(parent: parent,isAdd: condition, child: this);
    }else{
      return this;
    }
  }
}
