import { Controller, Post, Body, UseGuards, Get, Request } from '@nestjs/common';
import { AuthService } from './auth.service';
import { Public } from '../../common/decorators/public.decorator';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('nonce')
  async getNonce(@Body('walletAddress') walletAddress: string) {
    return this.authService.generateSignMessage(walletAddress);
  }

  @Public()
  @Post('verify')
  async verifySignature(
    @Body() body: { walletAddress: string; signature: string; nonce: string },
  ) {
    const { walletAddress, signature, nonce } = body;
    return this.authService.verifySignature(walletAddress, signature, nonce);
  }

  @Post('refresh')
  async refreshToken(@Request() req: any) {
    return this.authService.refreshToken(req.user.sub, req.user.walletAddress);
  }

  @Get('me')
  async getCurrentUser(@Request() req: any) {
    return req.user;
  }
}
