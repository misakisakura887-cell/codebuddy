import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  walletAddress: string;

  @Column({ nullable: true })
  username: string;

  @Column({ nullable: true })
  email: string;

  @Column({ nullable: true })
  avatarUrl: string;

  @Column({ default: false })
  isStrategist: boolean;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  strategistScore: number;

  @Column({ default: 0 })
  totalFollowers: number;

  @Column({ default: 0 })
  totalCopies: number;

  @Column({ nullable: true, type: 'text' })
  bio: string;

  @Column({ nullable: true })
  twitterHandle: string;

  @Column({ nullable: true })
  discordHandle: string;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relations
  // @OneToMany(() => Strategy, (strategy) => strategy.user)
  // strategies: Strategy[];

  // @OneToMany(() => Trade, (trade) => trade.user)
  // trades: Trade[];
}
