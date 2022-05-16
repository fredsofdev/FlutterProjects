import 'package:equatable/equatable.dart';

class RoomsList extends Equatable {
  final int mId;
  final int mPlayersCount;
  final int mMaxCount;
  final String mName;
  final String mState;
  final String mStreamId;
  final String mVideoUrl;
  final String mPlayTimeSec;
  final String mIp;
  final String mPort;
  final String mStage;
  final String mCoin;
  final int mPrize;
  final int mPrice;

  const RoomsList(
      {this.mId,
      this.mPlayersCount,
      this.mMaxCount,
      this.mName,
      this.mState,
      this.mCoin,
      this.mIp,
      this.mPort,
      this.mPlayTimeSec,
      this.mStreamId,
      this.mVideoUrl,
      this.mPrice,
      this.mPrize,
      this.mStage});

  static const empty = RoomsList();

  factory RoomsList.fromMap(Map<dynamic, dynamic> data) {
    return RoomsList(
        mId: data['m_id'] as int,
        mPlayersCount: data['m_currentPlayers'] as int ?? 0,
        mMaxCount: int.parse(data['m_maxPlayer'].toString()) ?? 0,
        mName: "Machine_${data['m_id']}" ?? "",
        mState: data['m_state'].toString() ?? "",
        mCoin: data['m_coin'].toString() ?? "play_coin",
        mPrice: data['m_price'] as int ?? 0,
        mPrize: data['m_prize'] as int ?? 0,
        mIp: data['m_ip'].toString() ?? "",
        mPort: data['m_port'].toString() ?? "",
        mPlayTimeSec: data['m_playTimeSec'].toString() ?? "",
        mStreamId: data['m_streamId'].toString() ?? "",
        mVideoUrl: data['m_videoUrl'].toString() ?? "",
        mStage: data['m_stage'].toString() ?? "");
  }

  @override
  // TODO: implement props
  List<Object> get props => [
        mId,
        mPlayersCount,
        mMaxCount,
        mName,
        mState,
        mCoin,
        mStreamId,
        mVideoUrl,
        mStreamId,
        mPort,
        mIp,
        mPrice,
        mPrize,
        mStage
      ];
}
