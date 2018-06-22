push!(LOAD_PATH,"../")

include("testing_dipole_response.jl")
using Plots

"""
Atomic units:
-------------------------
kb = 1
hbar = 1
4*pi*e0 = 1
a_0 = 1
e = 1
-------------------------
distance = bohr (a_0)
energy = hartree (27.211385 eV)
time = hbar/E_h (2.418884326505(16)×10−17 s)
dipole moment = ea_0 (8.47835326(19)×10−30 C·m = 2.541746 Debye)
polarisability = e2 a_02/E_h (1.65E-41 C^2 m^2 /J)
temperature = E_h/kB (3.1577464E5 K)
"""

#'''SetUp'''
const kB=1 #8.6173324E-5 #eV
const hbar=1.0

const N=50 # Number of sites in model
             # --> Size of tridiagonal Hamiltonian constructed; larger value -> better statistics, slower runtime
const Edisorder=0.0 # Energetic disorder eV, Gaussian form
const Jdisorder=0.0 # Transfer integral disorder, eV.
const r = 20

# Model setup
const J0=0.004 #(~0.1eV)
modelJ(θ) = J0*cos(θ*π/180.0).^2

const T=0.0032 #(~300K)
const B=1/(T*kB) #300K * k_B in eV

# This effectively reduces down to the 'alpha' parameter in the Frohlich polaron Hamiltonian
const dipolestrength=0.2

function TestNewDipole()
    #'''prepare'''
    S,E,H,psi,density = prepare_model()
    dipole = zeros(N)
    Field = FieldFromDensity(density)
    S,E,H = UpdateEnergy(dipole, Field, S, E)
    dipole = UpdateDipole(Field,density)


    psi=psi+nondispersive_wavepacket(20,4.0)
    normalise = norm(psi)
    psi = psi/normalise
    density = conj(psi).*psi
    #plot(real(density))
    #gui()
    Field = FieldFromDensity(density)
    dipole = UpdateDipole(Field,density)
    S,E,H = UpdateEnergy(dipole, Field, S, E)
    norm_dipole = norm(dipole)
    #plot(real(dipole/norm_dipole))
    #gui()


    #'''propagate'''
    for i in 1:1000
        norm_dipole = norm(dipole)
        plot(real(dipole/norm_dipole), label = "dipole")
        #plot!(imag(psi))
        #plot!(real(psi))
        xlims!(1,N)
        ylims!(-1,1)
        plot!(real(density), label = "density")
        gui()
        psi, density = Propagate(H,psi,10)
        Field = FieldFromDensity(real(density))
        dipole = UpdateDipole(Field, density)
        S,E,H = UpdateEnergy(dipole, Field, S, E)

    end

end

TestNewDipole()
