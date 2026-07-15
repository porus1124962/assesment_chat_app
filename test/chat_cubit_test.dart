import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:assesment_chat_app/domain/entities/message.dart';
import 'package:assesment_chat_app/data/repositories/chat_repository_impl.dart';
import 'package:assesment_chat_app/domain/repositories/message_repository.dart';
import 'package:assesment_chat_app/presentation/cubits/chat/chat_cubit.dart';
import 'package:assesment_chat_app/presentation/cubits/chat/chat_state.dart';

class MockChatRepository extends Mock implements ChatRepositoryImpl {}
class MockMessageRepository extends Mock implements MessageRepository {}

void main() {
  late ChatCubit chatCubit;
  late MockChatRepository mockChatRepository;
  late MockMessageRepository mockMessageRepository;

  setUp(() {
    mockChatRepository = MockChatRepository();
    mockMessageRepository = MockMessageRepository();
    chatCubit = ChatCubit(
      chatRepository: mockChatRepository,
      messageRepository: mockMessageRepository,
    );
  });

  tearDown(() => chatCubit.close());

  group('ChatCubit', () {
    final testMessages = [
      Message(
        id: 'msg-1',
        senderId: 'user-1',
        receiverId: 'user-2',
        text: 'Hello',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      ),
      Message(
        id: 'msg-2',
        senderId: 'user-2',
        receiverId: 'user-1',
        text: 'Hi there',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      ),
    ];

    group('fetchMessages', () {
      blocTest<ChatCubit, ChatState>(
        'emits [ChatLoading, ChatLoaded] when messages are fetched successfully',
        build: () {
          when(
            () => mockChatRepository.getMessagesStream('user-1', 'user-2'),
          ).thenAnswer((_) async* {
            yield testMessages;
          });
          return chatCubit;
        },
        act: (cubit) => cubit.fetchMessages('user-1', 'user-2'),
        expect: () => [
          isA<ChatLoading>(),
          isA<ChatLoaded>()
              .having((state) => state.messages.length, 'length', 2)
              .having((state) => state.messages[0].id, 'first message id', 'msg-1'),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'emits [ChatLoading, ChatEmpty] when no messages are found',
        build: () {
          when(
            () => mockChatRepository.getMessagesStream('user-1', 'user-2'),
          ).thenAnswer((_) async* {
            yield [];
          });
          return chatCubit;
        },
        act: (cubit) => cubit.fetchMessages('user-1', 'user-2'),
        expect: () => [
          isA<ChatLoading>(),
          isA<ChatEmpty>(),
        ],
      );
    });

    group('sendMessage', () {
      blocTest<ChatCubit, ChatState>(
        'emits [MessageSending, MessageSent, ChatLoaded] when message is sent successfully',
        build: () {
          when(
            () => mockChatRepository.sendMessage(any()),
          ).thenAnswer((_) async => {});
          return chatCubit;
        },
        act: (cubit) => cubit.sendMessage(
          currentUserId: 'user-1',
          receiverId: 'user-2',
          messageText: 'Test message',
        ),
        expect: () => [
          isA<MessageSending>(),
          isA<MessageSent>(),
          isA<ChatLoaded>(),
        ],
      );

      blocTest<ChatCubit, ChatState>(
        'emits error state when message sending fails',
        build: () {
          when(
            () => mockChatRepository.sendMessage(any()),
          ).thenThrow(Exception('Send failed'));
          return chatCubit;
        },
        act: (cubit) => cubit.sendMessage(
          currentUserId: 'user-1',
          receiverId: 'user-2',
          messageText: 'Test message',
        ),
        expect: () => [
          isA<MessageSending>(),
          isA<ChatError>(),
          isA<ChatLoaded>(),
        ],
      );
    });

    group('resetChat', () {
      blocTest<ChatCubit, ChatState>(
        'emits ChatInitial when reset is called',
        build: () => chatCubit,
        act: (cubit) => cubit.resetChat(),
        expect: () => [
          isA<ChatInitial>(),
        ],
      );
    });
  });
}
