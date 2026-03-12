import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { verifyMessage } from 'ethers';
import { UserService } from '../user/user.service';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class AuthService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly userService: UserService,
  ) {}

  /**
   * 生成签名消息
   */
  async generateSignMessage(walletAddress: string): Promise<{ message: string; nonce: string }> {
    const nonce = uuidv4();
    const timestamp = Date.now();
    const message = `Sign this message to authenticate with QuantTrade Web3.\n\nWallet: ${walletAddress}\nNonce: ${nonce}\nTimestamp: ${timestamp}`;

    // TODO: 存储nonce到Redis，设置5分钟过期
    // await this.redisService.set(`nonce:${walletAddress}`, nonce, 300);

    return { message, nonce };
  }

  /**
   * 验证钱包签名
   */
  async verifySignature(
    walletAddress: string,
    signature: string,
    nonce: string,
  ): Promise<{ accessToken: string; refreshToken: string; user: any }> {
    // TODO: 从Redis验证nonce
    // const storedNonce = await this.redisService.get(`nonce:${walletAddress}`);
    // if (storedNonce !== nonce) {
    //   throw new UnauthorizedException('Invalid nonce');
    // }

    // 构建原始消息
    const message = `Sign this message to authenticate with QuantTrade Web3.\n\nWallet: ${walletAddress}\nNonce: ${nonce}\nTimestamp: ${Date.now()}`;

    // 验证签名
    const recoveredAddress = verifyMessage(message, signature);
    if (recoveredAddress.toLowerCase() !== walletAddress.toLowerCase()) {
      throw new UnauthorizedException('Invalid signature');
    }

    // 查找或创建用户
    let user = await this.userService.findByWalletAddress(walletAddress);
    if (!user) {
      user = await this.userService.create({
        walletAddress: walletAddress.toLowerCase(),
      });
    }

    // 生成JWT
    const payload = { sub: user.id, walletAddress: user.walletAddress };
    const accessToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get('JWT_EXPIRES_IN', '1h'),
    });
    const refreshToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN', '7d'),
    });

    // TODO: 删除已使用的nonce
    // await this.redisService.del(`nonce:${walletAddress}`);

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        walletAddress: user.walletAddress,
        username: user.username,
        avatarUrl: user.avatarUrl,
        isStrategist: user.isStrategist,
      },
    };
  }

  /**
   * 验证JWT token
   */
  async validateUser(userId: string, walletAddress: string): Promise<any> {
    const user = await this.userService.findById(userId);
    if (user && user.walletAddress === walletAddress) {
      return user;
    }
    return null;
  }

  /**
   * 刷新token
   */
  async refreshToken(userId: string, walletAddress: string): Promise<{ accessToken: string; refreshToken: string }> {
    const payload = { sub: userId, walletAddress };
    const accessToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get('JWT_EXPIRES_IN', '1h'),
    });
    const refreshToken = this.jwtService.sign(payload, {
      expiresIn: this.configService.get('JWT_REFRESH_EXPIRES_IN', '7d'),
    });

    return { accessToken, refreshToken };
  }
}
