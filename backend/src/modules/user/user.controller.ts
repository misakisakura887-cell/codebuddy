import { Controller, Get, Put, Body, Request, UseGuards } from '@nestjs/common';
import { UserService } from './user.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Get('me')
  async getCurrentUser(@Request() req: any) {
    return this.userService.findById(req.user.id);
  }

  @Put('me')
  async updateCurrentUser(@Request() req: any, @Body() body: any) {
    const { username, email, avatarUrl, bio, twitterHandle, discordHandle } = body;
    return this.userService.update(req.user.id, {
      username,
      email,
      avatarUrl,
      bio,
      twitterHandle,
      discordHandle,
    });
  }

  @Get('strategists')
  async getTopStrategists() {
    return this.userService.getTopStrategists(20);
  }
}
