# mdp step simulator and stepthrough
@testset "gridstepsim" begin
    p = GridWorld()
    solver = RandomSolver(MersenneTwister(2))
    policy = solve(solver, p)
    sim = StepSimulator("s,sp,r,a,ai", rng=MersenneTwister(3), max_steps=100)
    n_steps = 0
    for (s, sp, r, a, ai) in simulate(sim, p, policy)
        @test isa(s, statetype(p))
        @test isa(sp, statetype(p))
        @test isa(r, Float64)
        @test isa(a, actiontype(p))
        @test isa(ai, Nothing)
        n_steps += 1
    end
    @test n_steps <= 100

    n_steps = 0
    for s in stepthrough(p, policy, "s", rng=MersenneTwister(4), max_steps=100)
        @test isa(s, statetype(p))
        n_steps += 1
    end
    @test n_steps <= 100
end


# pomdp step simulator and stepthrough
@testset "babystepsim" begin
    p = BabyPOMDP()
    policy = FeedWhenCrying()
    up = PreviousObservationUpdater()
    sim = StepSimulator("s,sp,r,a,b,ui,i,ai", rng=MersenneTwister(3), max_steps=100)
    s_init = rand(sim.rng, [true, false])
    b_init = false
    n_steps = 0
    for (s, sp, r, a, b, ui, i, ai) in simulate(sim, p, policy, up, b_init, s_init)
        @test isa(s, statetype(p))
        @test isa(sp, statetype(p))
        @test isa(r, Float64)
        @test isa(a, actiontype(p))
        @test isa(b, Bool)
        @test isa(ui, Nothing)
        @test isa(ai, Nothing)
        n_steps += 1
    end
    @test n_steps == 100
end
@testset "stepthroughfeed" begin
    p = BabyPOMDP()
    policy = FeedWhenCrying()
    up = PreviousObservationUpdater()
    s_init = rand(MersenneTwister(3), [true, false])
    b_init = false
    n_steps = 0
    for r in stepthrough(p, policy, up, b_init, s_init, "r", rng=MersenneTwister(4), max_steps=100)
        @test isa(r, Float64)
        @test r <= 0
        n_steps += 1
    end
    @test n_steps == 100
end

# example from stepthrough documentation
@testset "stepthroughrand" begin
    p = BabyPOMDP()
    policy = RandomPolicy(p)

    for (s, a, o, r) in stepthrough(p, policy, "s,a,o,r", max_steps=10)
        println("in state $s")
        println("took action $o")
        println("received observation $o and reward $r")
    end
end
