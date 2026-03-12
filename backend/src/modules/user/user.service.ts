import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async findByWalletAddress(walletAddress: string): Promise<User | null> {
    return this.userRepository.findOne({
      where: { walletAddress: walletAddress.toLowerCase() },
    });
  }

  async findById(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  async create(data: Partial<User>): Promise<User> {
    const user = this.userRepository.create(data);
    return this.userRepository.save(user);
  }

  async update(id: string, data: Partial<User>): Promise<User> {
    const user = await this.findById(id);
    if (!user) {
      throw new NotFoundException('User not found');
    }
    Object.assign(user, data);
    return this.userRepository.save(user);
  }

  async updateStrategistScore(userId: string, score: number): Promise<void> {
    await this.userRepository.update(userId, { strategistScore: score });
  }

  async incrementFollowers(userId: string): Promise<void> {
    await this.userRepository.increment({ id: userId }, 'totalFollowers', 1);
  }

  async decrementFollowers(userId: string): Promise<void> {
    await this.userRepository.decrement({ id: userId }, 'totalFollowers', 1);
  }

  async getTopStrategists(limit: number = 20): Promise<User[]> {
    return this.userRepository.find({
      where: { isStrategist: true, isActive: true },
      order: { strategistScore: 'DESC' },
      take: limit,
    });
  }
}
