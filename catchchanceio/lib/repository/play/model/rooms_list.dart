import 'package:equatable/equatable.dart';

class RoomsList extends Equatable {
  final int? mId;
  final int? mPlayersCount;
  final int? mMaxCount;
  final String? mName;
  final String? mState;
  final String? mStreamId;
  final String? mVideoUrl;
  final String? mPlayTimeSec;
  final String? mIp;
  final String? mPort;
  final String? mStage;
  final String? mCoin;
  final int? mPrize;
  final int? mPrice;

  const RoomsList(
      {this.mId = 0,
      this.mPlayersCount = 0,
      this.mMaxCount = 0,
      this.mName = "",
      this.mState = "running",
      this.mCoin = "play_coin",
      this.mIp = "2",
      this.mPort = "1",
      this.mPlayTimeSec = "2",
      this.mStreamId = "1",
      this.mVideoUrl = "h",
      this.mPrice = 0,
      this.mPrize = 0,
      this.mStage = "stage1"});

  static const empty = RoomsList();

  factory RoomsList.fromMap(Map<dynamic, dynamic> data) {
    return RoomsList(
        mId: data['m_id'] as int,
        mPlayersCount: data['m_currentPlayers'] as int,
        mMaxCount: int.parse(data['m_maxPlayer'].toString()) ,
        mName: "Machine_${data['m_id']}" ,
        mState: data['m_state'].toString() ,
        mCoin: data['m_coin'].toString(),
        mPrice: data['m_price'] as int,
        mPrize: data['m_prize'] as int ,
        mIp: data['m_ip'].toString() ,
        mPort: data['m_port'].toString() ,
        mPlayTimeSec: data['m_playTimeSec'].toString() ,
        mStreamId: data['m_streamId'].toString() ,
        mVideoUrl: data['m_videoUrl'].toString() ,
        mStage: data['m_stage'].toString());
  }

  @override
  // TODO: implement props
  List<Object> get props => [
        mId!,
        mPlayersCount!,
        mMaxCount!,
        mName!,
        mState!,
        mCoin!,
        mStreamId!,
        mVideoUrl!,
        mStreamId!,
        mPort!,
        mIp!,
        mPrice!,
        mPrize!,
        mStage!
      ];
}
