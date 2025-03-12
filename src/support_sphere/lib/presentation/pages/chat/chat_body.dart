import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:support_sphere/data/models/auth_user.dart';
import 'package:support_sphere/logic/bloc/auth/authentication_bloc.dart';
import 'package:support_sphere/logic/cubit/profile_cubit.dart';
import 'package:support_sphere/constants/string_catalog.dart';

/// Chat Body Widget
class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthUser authUser = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );

    return BlocProvider(
      create: (context) => ProfileCubit(authUser),
      child: LayoutBuilder(builder: (context, constraint) {
        return Column(
          children: [
            SizedBox(
              height: 50,
              child: const Center(
                // TODO: Add profile picture
                child: Text(UserProfileStrings.userProfile,
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: Container(
                height: MediaQuery.sizeOf(context).height,
                padding: const EdgeInsets.all(10),
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: const [

                  ],
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
