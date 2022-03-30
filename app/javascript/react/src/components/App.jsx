import * as React from 'react'                          
import axios from "axios"
import { Header, Grid, Input, Card, Icon } from 'semantic-ui-react'

class App extends React.Component{
    constructor(props) {
        super(props)
        this.searchInput = React.createRef()
        this.state = {
            fridgeStockIngredients: '',
            gridDisplay: 'none',
            loading:false,
            recipes: [{
                recipe: 1, 
                relevance: '',
                ingredients: []
            }]
        }
    }
    
    handleKeyDown(e){
        this.updateInput(e)
        if (e.key === 'Enter') {
            this.searchRecipes()
        }
    }

    updateInput(e){
        this.setState({fridgeStockIngredients: e.target.value})
    }

    searchRecipes() {
        this.setState({loading: true})

        axios.get("/search?q=" + this.state.fridgeStockIngredients)
            .then((res) => 
                this.setState({
                    recipes: res.data,
                    loading: false, 
                    gridDisplay: 'flex'})
            )

        // this.setState({
        //     recipes: [{"id": 3, "title": 'This is a test recipe'}]
        // })
    }

    showRecipeCompletenessRibbon(complete){
        if (complete == true) {
            return (
                <a className='ui right olive ribbon label' style={{margin: '10px 0'}}>Complete Recipe</a>
            )
        }
    }
    
    componentDidMount(){
        this.searchInput.current.focus();
    }

    render() {
        return (
            <div className='ui container-fluid'> 
                <Grid>
                    <Grid.Column width={8} style={{marginTop: 20}} className='centered'>
                        <Header as='h1'>
                            Welcome to PrepareDinner v0.1-beta
                            <Header.Subheader>
                            Type your search to find relevant recipes for given ingredients.
                            For multiple ingredients use comma separated words.
                            </Header.Subheader>
                        </Header>
                        <Input
                            id='search-input'
                            ref={this.searchInput }
                            size='huge'
                            fluid icon='search' 
                            placeholder='eggs,bacon,bread'
                            loading={this.state.loading}
                            onChange={e => this.updateInput(e)}
                            onKeyDown={e => this.handleKeyDown(e)}
                        />
                    </Grid.Column>
                </Grid>
                <Grid className='container' style={{display: this.state.gridDisplay} }>
                    <Grid.Column width={16}>
                        <Card.Group itemsPerRow={4}>
                        {
                            this.state.recipes.map((recipe, recipeIndex) =>
                                <Card key={recipeIndex} className={recipe.class}>
                                    {/* <div style={{backgroundImage: `url(${recipe.image_url})`,
                                                overflow: 'hidden',
                                                borderRadius: 3,
                                                border: 1,
                                                borderColor: '#ccc',
                                                backgroundSize: 'cover', 
                                                height: 140,
                                                margin: '0'}}>
                                    </div> */}
                                    <Card.Content>
                                    <Card.Header>{recipe.title}</Card.Header>
                                    <Card.Meta>
                                        <span className='date'>{recipe.recipe_category}</span><br />
                                        <span className='date'>Rating {recipe.rating}</span>
                                    </Card.Meta>
                                    {this.showRecipeCompletenessRibbon(recipe.complete)}                 
                                    <Card.Description>
                                        {
                                        recipe.ingredients.map((incredient, incredientIndex) => 
                                            <div className='incredient' key={incredientIndex}>- {incredient.name}</div>
                                            )
                                        }
                                    </Card.Description>
                                    </Card.Content>
                                    <Card.Content extra>
                                        <Grid>
                                            <Grid.Column width={2}>
                                                <Icon name='time' />
                                            </Grid.Column>
                                            <Grid.Column width={13}>
                                                Preperation Time: {recipe.prep_time} <br/>
                                                Cooking Time: {recipe.cook_time} <br/>
                                            </Grid.Column>
                                        </Grid>
                                        <Grid>
                                            <Grid.Column width={2} style={{color: '#cccccc9e'}}>
                                                <Icon name='bug' />
                                            </Grid.Column>
                                            <Grid.Column width={13} style={{color: '#cccccc9e'}}>
                                                Matched Ingredients: {recipe.matched_ingredients_count} <br/>
                                                Non Matched Ingredients: {recipe.non_matched_ingredients_count} <br/>
                                                Completeness: {recipe.completeness} %<br/>
                                            </Grid.Column>
                                        </Grid>
                                    </Card.Content>
                                </Card>                    
                            )
                        }
                        </Card.Group>
                    </Grid.Column>
                </Grid>
            </div>
        )                   
    }
}
                                                        
export default App